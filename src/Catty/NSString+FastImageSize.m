/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
//
//  NSString+FastImageSize.m
//  Additions
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "NSString+FastImageSize.h"

@implementation NSString (FastImageSize)

#define JPEG_HEADER (uint8_t[2]){ 0xff, 0xd8 }
#define JPEG_EXIF_HEADER (uint8_t[4]){ 'E', 'x', 'i', 'f' }
#define PNG_HEADER (uint8_t[8]){ 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }
#define GIF_HEADER (uint8_t[3]){ 'G', 'I', 'F' }
#define BMP_HEADER (uint8_t[2]){ 0x42, 0x4D }

#define EXIF_TAG_ORIENTATION 0x0112
#define EXIF_TAG_PIX_XDIM 0xA002
#define EXIF_TAG_PIX_YDIM 0xA003
#define EXIF_TAG_IFD 0x8769

#define READ_UINT16 (fread(buffer, 1, 2, file) == 2)
#define LAST_UINT16 (uint16_t)(littleEndian ? (buffer[0] | buffer[1] << 8) : (buffer[1] | buffer[0] << 8))
#define READ_UINT32 (fread(buffer, 1, 4, file) == 4)
#define LAST_UINT32 (uint32_t)(littleEndian ? (buffer[0] | buffer[1] << 8 | buffer[2] << 16 | buffer[3] << 24) : (buffer[3] | buffer[2] << 8 | buffer[1] << 16 | buffer[0] << 24))

- (CGSize)sizeOfImageForFilePath
{
    BOOL success = NO;
    CGSize size = CGSizeZero;
    
    FILE *file = fopen([[NSFileManager defaultManager] fileSystemRepresentationWithPath:self], "r");
    if (file)
        {
        uint8_t buffer[4];
        if (fread(buffer, 1, 2, file) == 2 &&
            memcmp(buffer, JPEG_HEADER, 2) == 0)
            {// JPEG
                size = [self sizeOfImageForFilePath_JPEG:file];
                success = size.width > 0.f && size.height > 0.f;
            }
        
        if (!success)
            {
            fseek(file, 0, SEEK_SET);
            
            uint8_t buffer8[8];
            if (fread(buffer8, 1, 8, file) == 8 &&
                memcmp(buffer8, PNG_HEADER, 8) == 0)
                {
                // PNG
                
                if (!fseek(file, 8, SEEK_CUR))
                    {
                    if (fread(buffer, 1, 4, file) == 4)
                        {
                        size.width = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
                        }
                    if (fread(buffer, 1, 4, file) == 4)
                        {
                        size.height = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
                        success = YES;
                        }
                    }
                }
            }
        
        if (!success)
            {
            fseek(file, 0, SEEK_SET);
            
            if (fread(buffer, 1, 3, file) == 3 &&
                memcmp(buffer, GIF_HEADER, 3) == 0)
                {
                // GIF
                
                if (!fseek(file, 3, SEEK_CUR)) // 87a / 89a
                    {
                    if (fread(buffer, 1, 4, file) == 4)
                        {
                        size = (CGSize){*((int16_t*)buffer), *((int16_t*)(buffer + 2))};
                        success = YES;
                        }
                    }
                }
            }
        
        if (!success)
            {
            fseek(file, 0, SEEK_SET);
            
            if (fread(buffer, 1, 2, file) == 2 &&
                memcmp(buffer, BMP_HEADER, 2) == 0)
                {
                // BMP
                
                if (!fseek(file, 16, SEEK_CUR))
                    {
                    if (fread(buffer, 1, 4, file) == 4)
                        {
                        size.width = *((int32_t*)buffer);
                        }
                    if (fread(buffer, 1, 4, file) == 4)
                        {
                        size.height = *((int32_t*)buffer);
                        // success = YES; // Not needed, analyzer...
                        }
                    }
                }
            }
        
        fclose(file);
        }
    
    return size;
}

- (CGSize)sizeOfImageForFilePath_JPEG:(FILE *)file
{
    uint8_t buffer[4];
    
    while (fread(buffer, 1, 2, file) == 2 && buffer[0] == 0xFF &&
           ((buffer[1] >= 0xE0 && buffer[1] <= 0xEF) ||
            buffer[1] == 0xDB ||
            buffer[1] == 0xC0))
        {
        if (buffer[1] == 0xE1)
            { // Parse APP1 EXIF
                
                fpos_t offset;
                if (fgetpos(file, &offset)) return CGSizeZero;
                
                // Marker segment length
                
                if (fread(buffer, 1, 2, file) != 2) return CGSizeZero;
                // int blockLength = ((buffer[0] << 8) | buffer[1]) - 2;
                
                // Exif
                if (fread(buffer, 1, 4, file) != 4 ||
                    memcmp(buffer, JPEG_EXIF_HEADER, 4) != 0) return CGSizeZero;
                
                // Read Byte alignment offset
                if (fread(buffer, 1, 2, file) != 2 ||
                    buffer[0] != 0x00 || buffer[1] != 0x00) return CGSizeZero;
                
                // Read Byte alignment
                if (fread(buffer, 1, 2, file) != 2) return CGSizeZero;
                
                bool littleEndian = false;
                if (buffer[0] == 0x49 && buffer[1] == 0x49)
                    {
                    littleEndian = true;
                    }
                else if (buffer[0] != 0x4D && buffer[1] != 0x4D) return CGSizeZero;
                
                // TIFF tag marker
                if (!READ_UINT16 || LAST_UINT16 != 0x002A) return CGSizeZero;
                
                // Directory offset bytes
                if (!READ_UINT32) return CGSizeZero;
                uint32_t dirOffset = LAST_UINT32;
                
                int tag;
                uint16_t numberOfTags, tagType;
                uint32_t /*tagLength, */tagValue;
                int orientation = 1, width = 0, height = 0;
                uint32_t exifIFDOffset = 0;
                
                while (dirOffset != 0)
                    {
                    fseek(file, (long)offset + 8 + dirOffset, SEEK_SET);
                    
                    if (!READ_UINT16) return CGSizeZero;
                    numberOfTags = LAST_UINT16;
                    
                    for (uint16_t i = 0; i < numberOfTags; i++)
                        {
                        if (!READ_UINT16) return CGSizeZero;
                        tag = LAST_UINT16;
                        
                        if (!READ_UINT16) return CGSizeZero;
                        tagType = LAST_UINT16;
                        
                        if (!READ_UINT32) return CGSizeZero;
                        /*tagLength = LAST_UINT32*/;
                        
                        if (tag == EXIF_TAG_ORIENTATION ||
                            tag == EXIF_TAG_PIX_XDIM ||
                            tag == EXIF_TAG_PIX_YDIM ||
                            tag == EXIF_TAG_IFD)
                            {
                            switch (tagType)
                                {
                                    default:
                                    case 1:
                                    tagValue = fread(buffer, 1, 1, file) == 1 && buffer[0];
                                    fseek(file, 3, SEEK_CUR);
                                    break;
                                    case 3:
                                    if (!READ_UINT16) return CGSizeZero;
                                    tagValue = LAST_UINT16;
                                    fseek(file, 2, SEEK_CUR);
                                    break;
                                    case 4:
                                    case 9:
                                    if (!READ_UINT32) return CGSizeZero;
                                    tagValue = LAST_UINT32;
                                    break;
                                }
                            
                            if (tag == EXIF_TAG_ORIENTATION)
                                { // Orientation tag
                                    orientation = (int)tagValue;
                                }
                            else if (tag == EXIF_TAG_PIX_XDIM)
                                { // Width tag
                                    width = (int)tagValue;
                                }
                            else if (tag == EXIF_TAG_PIX_YDIM)
                                { // Height tag
                                    height = (int)tagValue;
                                }
                            else if (tag == EXIF_TAG_IFD)
                                { // EXIF IFD offset tag
                                    exifIFDOffset = tagValue;
                                }
                            }
                        else
                            {
                            fseek(file, 4, SEEK_CUR);
                            }
                        }
                    
                    if (dirOffset == exifIFDOffset)
                        {
                        break;
                        }
                    
                    if (!READ_UINT32) return CGSizeZero;
                    dirOffset = LAST_UINT32;
                    
                    if (dirOffset == 0)
                        {
                        dirOffset = exifIFDOffset;
                        }
                    }
                
                if (width > 0 && height > 0)
                    {
                    if (orientation >= 5 && orientation <= 8)
                        {
                        return (CGSize){height, width};
                        }
                    else
                        {
                        return (CGSize){width, height};
                        }
                    }
                
                return CGSizeZero;
            }
        else if (buffer[1] == 0xC0)
            { // Parse SOF0 (Start of Frame baseline)
                
                // Skip LF, P
                if (fseek(file, 3, SEEK_CUR)) return CGSizeZero;
                
                // Read Y,X
                if (fread(buffer, 1, 4, file) != 4) return CGSizeZero;
                
                return (CGSize){buffer[2] << 8 | buffer[3], buffer[0] << 8 | buffer[1]};
            }
        else
            { // Skip APPn segment
                if (fread(buffer, 1, 2, file) == 2)
                    { // Marker segment length
                        fseek(file, (int)((buffer[0] << 8) | buffer[1]) - 2, SEEK_CUR);
                    }
                else
                    {
                    return CGSizeZero;
                    }
            }
        }
    
    return CGSizeZero;
}

@end