//
//  SPProgram.m
//  Sparrow
//
//  Created by Daniel Sperl on 14.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPProgram.h"

#import <GLKit/GLKit.h>

@implementation SPProgram
{
    uint _name;
    NSString *_vertexShader;
    NSString *_fragmentShader;
    NSMutableDictionary *_uniforms;
    NSMutableDictionary *_attributes;
}

@synthesize name = _name;
@synthesize vertexShader = _vertexShader;
@synthesize fragmentShader = _fragmentShader;

- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader
{
    if ((self = [super init]))
    {
        _vertexShader = vertexShader;
        _fragmentShader = fragmentShader;
        
        [self compile];
        [self updateUniforms];
        [self updateAttributes];
    }
    
    return self;
}

- (id)init
{
    return nil;
}

- (void)compile
{
    uint program = glCreateProgram();
    uint vertexShader   = [self compileShader:_vertexShader type:GL_VERTEX_SHADER];
    uint fragmentShader = [self compileShader:_fragmentShader type:GL_FRAGMENT_SHADER];
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    
  #if DEBUG
    
    int linked = 0;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    
    if (!linked)
    {
        int logLength = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        
        if (logLength)
        {
            char *log = malloc(sizeof(char) * logLength);
            glGetProgramInfoLog(program, logLength, NULL, log);
            NSLog(@"Error linking program: %s", log);
            free(log);
        }
    }
    
  #endif
    
    glDetachShader(program, vertexShader);
    glDetachShader(program, fragmentShader);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    _name = program;
}


- (uint)compileShader:(NSString *)source type:(GLenum)type
{
    uint shader = glCreateShader(type);
    if (!shader) return shader;
    
    const char *utfSource = [source UTF8String];
    
    glShaderSource(shader, 1, &utfSource, NULL);
    glCompileShader(shader);
    
  #if DEBUG
    
    int compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled)
    {
        int logLength = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        
        if (logLength)
        {
            char *log = malloc(sizeof(char) * logLength);
            glGetShaderInfoLog(shader, logLength, NULL, log);
            NSLog(@"Error compiling %@ shader: %s",
                  type == GL_VERTEX_SHADER ? @"vertex" : @"fragment", log);
            free(log);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    
  #endif
    
    return shader;
}

- (void)updateUniforms
{
    const int MAX_NAME_LENGTH = 64;
    char rawName[MAX_NAME_LENGTH];
    
    int numUniforms = 0;
    glGetProgramiv(_name, GL_ACTIVE_ATTRIBUTES, &numUniforms);
    
    _uniforms = [[NSMutableDictionary alloc] initWithCapacity:numUniforms];
    
    for (int i=0; i<numUniforms; ++i)
    {
        glGetActiveUniform(_name, i, MAX_NAME_LENGTH, NULL, NULL, NULL, rawName);
        NSString *name = [[NSString alloc] initWithCString:rawName encoding:NSUTF8StringEncoding];
        _uniforms[name] = @(i);
    }
}

- (void)updateAttributes
{
    const int MAX_NAME_LENGTH = 64;
    char rawName[MAX_NAME_LENGTH];
    
    int numAttributes = 0;
    glGetProgramiv(_name, GL_ACTIVE_ATTRIBUTES, &numAttributes);
    
    _attributes = [[NSMutableDictionary alloc] initWithCapacity:numAttributes];
    
    for (int i=0; i<numAttributes; ++i)
    {
        glGetActiveAttrib(_name, i, MAX_NAME_LENGTH, NULL, NULL, NULL, rawName);
        NSString *name = [[NSString alloc] initWithCString:rawName encoding:NSUTF8StringEncoding];
        _attributes[name] = @(i);
    }
}

- (void)dealloc
{
    glDeleteProgram(_name);
}

- (int)uniformByName:(NSString *)name
{
    return [_uniforms[name] intValue];
}

- (int)attributeByName:(NSString *)name
{
    return [_attributes[name] intValue];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"[Program %d\n## VERTEX SHADER: ##\n%@\n## FRAGMENT SHADER: ##\n%@]",
            _name, _vertexShader, _fragmentShader];
}

@end
