//
// Created by hayashi311 on 15/03/13.
//

#import "HRRoutes.h"

#define kJLRouteWildcardComponentsKey @"kJLRouteWildcardComponentsKey"
static BOOL shouldDecodePlusSymbols = YES;

@implementation NSString (HRRoutes)

- (NSString *)HRRoutes_URLDecodedString {
    NSString *input = shouldDecodePlusSymbols ? [self stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, self.length)] : self;
    return [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)HRRoutes_URLParameterDictionary {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (self.length && [self rangeOfString:@"="].location != NSNotFound) {
        NSArray *keyValuePairs = [self componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in keyValuePairs) {
            NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
            // don't assume we actually got a real key=value pair. start by assuming we only got @[key] before checking count
            NSString *paramValue = pair.count == 2 ? pair[1] : @"";
            // CFURLCreateStringByReplacingPercentEscapesUsingEncoding may return NULL
            parameters[pair[0]] = [paramValue HRRoutes_URLDecodedString] ?: @"";
        }
    }

    return parameters;
}

@end

@interface HRRoutePattern : NSObject

@property (nonatomic, copy) NSString *pattern;

@property (nonatomic, strong) NSArray *patternPathComponents;
@end


@implementation HRRoutePattern

- (NSDictionary *)parametersForURL:(NSURL *)URL components:(NSArray *)URLComponents {
    NSDictionary *routeParameters = nil;

    if (!self.patternPathComponents) {
        self.patternPathComponents = [[self.pattern pathComponents] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];
    }

    // do a quick component count check to quickly eliminate incorrect patterns
    BOOL componentCountEqual = self.patternPathComponents.count == URLComponents.count;
    BOOL routeContainsWildcard = !NSEqualRanges([self.pattern rangeOfString:@"*"], NSMakeRange(NSNotFound, 0));
    if (componentCountEqual || routeContainsWildcard) {
        // now that we've identified a possible match, move component by component to check if it's a match
        NSUInteger componentIndex = 0;
        NSMutableDictionary *variables = [NSMutableDictionary dictionary];
        BOOL isMatch = YES;

        for (NSString *patternComponent in self.patternPathComponents) {
            NSString *URLComponent = nil;
            if (componentIndex < [URLComponents count]) {
                URLComponent = URLComponents[componentIndex];
            } else if ([patternComponent isEqualToString:@"*"]) { // match /foo by /foo/*
                URLComponent = [URLComponents lastObject];
            }

            if ([patternComponent hasPrefix:@":"]) {
                // this component is a variable
                NSString *variableName = [patternComponent substringFromIndex:1];
                NSString *variableValue = URLComponent;
                NSString *urlDecodedVariableValue = [variableValue HRRoutes_URLDecodedString];
                if ([variableName length] > 0 && [urlDecodedVariableValue length] > 0) {
                    variables[variableName] = urlDecodedVariableValue;
                }
            } else if ([patternComponent isEqualToString:@"*"]) {
                // match wildcards
                variables[kJLRouteWildcardComponentsKey] = [URLComponents subarrayWithRange:NSMakeRange(componentIndex, URLComponents.count-componentIndex)];
                isMatch = YES;
                break;
            } else if (![patternComponent isEqualToString:URLComponent]) {
                // a non-variable component did not match, so this route doesn't match up - on to the next one
                isMatch = NO;
                break;
            }
            componentIndex++;
        }

        if (isMatch) {
            routeParameters = variables;
        }
    }

    return routeParameters;
}

@end


@implementation HRRoutes {
    NSMutableDictionary *_patterns;
}

+ (HRRoutes *)sharedRoutes {
    static HRRoutes *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _patterns = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)registerViewController:(Class <HRRoutesViewController>)c {
    NSString *className = NSStringFromClass(c);
    HRRoutePattern* pattern = [[HRRoutePattern alloc] init];
    pattern.pattern = [c hr_urlPattern];
    _patterns[className] = pattern;
}

- (UIViewController *)instantiateViewControllerWithURL:(NSURL *)URL {
    NSArray *pathComponents = [(URL.pathComponents ?: @[]) filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];

    if ([URL.host rangeOfString:@"."].location == NSNotFound && ![URL.host isEqualToString:@"localhost"]) {
        // For backward compatibility, handle scheme://path/to/ressource as if path was part of the
        // path if it doesn't look like a domain name (no dot in it)
        pathComponents = [@[URL.host] arrayByAddingObjectsFromArray:pathComponents];
    }

    NSDictionary *params;
    NSString *className;

    for (NSString *key in _patterns.allKeys){
        HRRoutePattern *pattern = _patterns[key];
        params = [pattern parametersForURL:URL components:pathComponents];
        if (params){
            className = key;
            break;
        }
    }
    if (!params) {
        return nil;
    }

    Class<HRRoutesViewController> c = NSClassFromString(className);
    if (c){
        return [c controllerWithParameters:params];
    }
    return nil;
}

@end