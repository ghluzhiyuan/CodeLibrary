static main(void)
{
    auto fp, begin, end, dexbyte;  
    fp = fopen("D:\\zhengban.1", "wb");  
    begin = 0xC4FEE000;  
    end = 0xC58D1000;  
    for(dexbyte = begin; dexbyte < end; dexbyte++) 
    {
        fputc(Byte(dexbyte), fp);
    }
}
