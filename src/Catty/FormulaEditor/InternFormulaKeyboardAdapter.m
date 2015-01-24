/**
 *  Copyright (C) 2010-2015 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "InternFormulaKeyboardAdapter.h"

@implementation InternFormulaKeyboardAdapter

-(NSMutableArray *)createInternTokenListByResourceId:(int)resource name:(NSString*)name
{
    //USER VARIABLES
    
    if((resource==0) && [name length]!=0)
    {
        return [self buildUserVariable:name];
    }
    
    //STRING
    
    if(resource == TOKEN_TYPE_STRING)
    {
        return [self buildString:name];
    }
    
    switch (resource) {
        case TOKEN_TYPE_NUMBER_0:
            return [self buildNumber:[NSString stringWithFormat:@"%d",0]];
            break;
        case TOKEN_TYPE_NUMBER_1:
            return [self buildNumber:[NSString stringWithFormat:@"%d",1]];
            break;
        case TOKEN_TYPE_NUMBER_2:
            return [self buildNumber:[NSString stringWithFormat:@"%d",2]];
            break;
        case TOKEN_TYPE_NUMBER_3:
            return [self buildNumber:[NSString stringWithFormat:@"%d",3]];
            break;
        case TOKEN_TYPE_NUMBER_4:
            return [self buildNumber:[NSString stringWithFormat:@"%d",4]];
            break;
        case TOKEN_TYPE_NUMBER_5:
            return [self buildNumber:[NSString stringWithFormat:@"%d",5]];
            break;
        case TOKEN_TYPE_NUMBER_6:
            return [self buildNumber:[NSString stringWithFormat:@"%d",6]];
            break;
        case TOKEN_TYPE_NUMBER_7:
            return [self buildNumber:[NSString stringWithFormat:@"%d",7]];
            break;
        case TOKEN_TYPE_NUMBER_8:
            return [self buildNumber:[NSString stringWithFormat:@"%d",8]];
            break;
        case TOKEN_TYPE_NUMBER_9:
            return [self buildNumber:[NSString stringWithFormat:@"%d",9]];
            break;
            
            //FUNCTIONS
            
        case SIN:
            return [self buildSingleParameterFunction:SIN
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case COS:
            return [self buildSingleParameterFunction:COS
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case TAN:
            return [self buildSingleParameterFunction:TAN
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case LN:
            return [self buildSingleParameterFunction:LN
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case LOG:
            return [self buildSingleParameterFunction:LOG
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case PI_F:
            return [self buildFunctionWithoutParametersAndBrackets:PI_F];
            break;
        case SQRT:
            return [self buildSingleParameterFunction:SQRT
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case RAND:
            return [self buildDoubleParameterFunction:RAND
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]
                              withSecondParameterType:TOKEN_TYPE_NUMBER
                              andSecondParameterValue:[NSString stringWithFormat:@"%d",1]];
            break;
        case ABS:
            return [self buildSingleParameterFunction:ABS
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case ROUND:
            return [self buildSingleParameterFunction:ROUND
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case MOD:
            return [self buildDoubleParameterFunction:MOD
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",1]
                              withSecondParameterType:TOKEN_TYPE_NUMBER
                              andSecondParameterValue:[NSString stringWithFormat:@"%d",1]];
            break;
        case ARCSIN:
            return [self buildSingleParameterFunction:ARCSIN
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case ARCCOS:
            return [self buildSingleParameterFunction:ARCCOS
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case ARCTAN:
            return [self buildSingleParameterFunction:ARCTAN
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]];
            break;
        case EXP:
            return [self buildSingleParameterFunction:EXP
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",1]];
            break;
        case MAX:
            return [self buildDoubleParameterFunction:MAX
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]
                              withSecondParameterType:TOKEN_TYPE_NUMBER
                              andSecondParameterValue:[NSString stringWithFormat:@"%d",1]];
            break;
        case MIN:
            return [self buildDoubleParameterFunction:MIN
                               withFirstParameterType:TOKEN_TYPE_NUMBER
                                    andParameterValue:[NSString stringWithFormat:@"%d",0]
                              withSecondParameterType:TOKEN_TYPE_NUMBER
                              andSecondParameterValue:[NSString stringWithFormat:@"%d",1]];
            break;
        case TRUE_F:
            return [self buildFunctionWithoutParametersAndBrackets:TRUE_F];
            break;
        case FALSE_F:
            return [self buildFunctionWithoutParametersAndBrackets:FALSE_F];
            break;
        case POW:
            return [self buildFunctionWithoutParametersAndBrackets:POW];
            break;
        
        //PERIOD
            
        case DECIMAL_MARK:
            return [self buildPeriod];
            break;

        //OPERATOR
            
        case PLUS:
            return [self buildOperator:PLUS];
            break;
        case MINUS:
            return [self buildOperator:MINUS];
            break;
        case MULT:
            return [self buildOperator:MULT];
            break;
        case DIVIDE:
            return [self buildOperator:DIVIDE];
            break;
        case EQUAL:
            return [self buildOperator:EQUAL];
            break;
        case NOT_EQUAL:
            return [self buildOperator:NOT_EQUAL];
            break;
        case SMALLER_THAN:
            return [self buildOperator:SMALLER_THAN];
            break;
        case SMALLER_OR_EQUAL:
            return [self buildOperator:SMALLER_OR_EQUAL];
            break;
        case GREATER_THAN:
            return [self buildOperator:GREATER_THAN];
            break;
        case GREATER_OR_EQUAL:
            return [self buildOperator:GREATER_OR_EQUAL];
            break;
        case LOGICAL_AND:
            return [self buildOperator:LOGICAL_AND];
            break;
        case LOGICAL_OR:
            return [self buildOperator:LOGICAL_OR];
            break;
        case LOGICAL_NOT:
            return [self buildOperator:LOGICAL_NOT];
            break;
            
        //BRACKETS
            
        case BRACKET_OPEN:
            return [self buildBracketOpen];
            break;
        case BRACKET_CLOSE:
            return [self buildBracketClose];
            break;
            
        //COSTUME
            
        //SENSOR
        case COMPASS_DIRECTION:
            return [self buildSensor:COMPASS_DIRECTION];
            break;
        case LOUDNESS:
            return [self buildSensor:LOUDNESS];
            break;
        case OBJECT_BRIGHTNESS:
            return [self buildSensor:OBJECT_BRIGHTNESS];
            break;
        case OBJECT_GHOSTEFFECT:
            return [self buildSensor:OBJECT_GHOSTEFFECT];
            break;
        case OBJECT_LAYER:
            return [self buildSensor:OBJECT_LAYER];
            break;
        case OBJECT_ROTATION:
            return [self buildSensor:OBJECT_ROTATION];
            break;
        case OBJECT_SIZE:
            return [self buildSensor:OBJECT_SIZE];
            break;
        case OBJECT_X:
            return [self buildSensor:OBJECT_X];
            break;
        case OBJECT_Y:
            return [self buildSensor:OBJECT_Y];
            break;
        case X_ACCELERATION:
            return [self buildSensor:X_ACCELERATION];
            break;
        case X_INCLINATION:
            return [self buildSensor:X_INCLINATION];
            break;
        case Y_ACCELERATION:
            return [self buildSensor:Y_ACCELERATION];
            break;
        case Y_INCLINATION:
            return [self buildSensor:Y_INCLINATION];
            break;
        case Z_ACCELERATION:
            return [self buildSensor:Z_ACCELERATION];
            break;
            
        default:
            return nil;
            break;
            
    }
    
    
}

-(NSMutableArray *)buildUserVariable:(NSString *)name
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_USER_VARIABLE AndValue:name]];
    return returnList;
}

-(NSMutableArray *)buildString:(NSString *)name
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_STRING AndValue:name]];
    return returnList;
}

-(NSMutableArray *)buildNumber:(NSString *)numberValue
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_NUMBER
                                                  AndValue:numberValue]];
    return returnList;
}

-(NSMutableArray *)buildSingleParameterFunction:(Function)function
                         withFirstParameterType:(InternTokenType)firstParameter
                              andParameterValue:(NSString *)parameterValue
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_NAME
                                                  AndValue:[Functions getName:function]]];
    
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    
    [returnList addObject:[[InternToken alloc]initWithType:firstParameter
                                                  AndValue:parameterValue]];
    
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    return returnList;

}

-(NSMutableArray *)buildFunctionWithoutParametersAndBrackets:(Function)function
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_NAME
                                                  AndValue:[Functions getName:function]]];
    return returnList;
}

-(NSMutableArray *)buildDoubleParameterFunction:(Function)function
                         withFirstParameterType:(InternTokenType)firstParameter
                              andParameterValue:(NSString *)firstParameterValue
                        withSecondParameterType:(InternTokenType)secondParameter
                        andSecondParameterValue:(NSString *)secondParameterValue
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_NAME
                                                  AndValue:[Functions getName:function]]];
    
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN]];
    
    [returnList addObject:[[InternToken alloc]initWithType:firstParameter
                                                  AndValue:firstParameterValue]];
    
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER]];
    
    [returnList addObject:[[InternToken alloc]initWithType:secondParameter
                                                  AndValue:secondParameterValue]];
    
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE]];
    
    return returnList;
    
}

-(NSMutableArray *)buildPeriod{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_PERIOD]];
    return returnList;
}

-(NSMutableArray *)buildBracketOpen{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_BRACKET_OPEN]];
    return returnList;
}

-(NSMutableArray *)buildBracketClose{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_BRACKET_CLOSE]];
    return returnList;
}

-(NSMutableArray *)buildOperator:(Operator)operator
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_OPERATOR
                                                  AndValue:[Operators getName:operator]]];
    return returnList;
}

-(NSMutableArray *)buildSensor:(Sensor)sensor
{
    NSMutableArray *returnList = [[NSMutableArray alloc]init];
    [returnList addObject:[[InternToken alloc]initWithType:TOKEN_TYPE_SENSOR
                                                  AndValue:[SensorManager stringForSensor:sensor]]];
    return returnList;
}
@end
