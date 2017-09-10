auto fp, begin, end, dexbyte;  
fp = fopen("D:\\dump.dex", "wb");  
begin = 0x5faa2000;  
end = 0x5fb36000;  
for ( dexbyte = begin; dexbyte < end; dexbyte ++ )  
    fputc(Byte(dexbyte), fp); 
