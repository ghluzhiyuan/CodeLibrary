#!/usr/bin/python
# -*- coding: utf8 -*-
import os
import sys


DEBUG = False
def log(s):
    if DEBUG:
        print s


def pause():
    try:
        input()
    except:
        print "Bye ~ "
        

def main():
    current_path = sys.path[0]
    video_list =  os.listdir(current_path)
    for video_dir in video_list:
        video_path = os.path.join(current_path, video_dir) 
        
        if os.path.isdir(video_path):
            video_sub_list = os.listdir(video_path)

            video_2_path_dict = {}
            for video_sub_dir in video_sub_list:
            
                if video_sub_dir.startswith(video_dir):
                    video_ts_path = os.path.join(video_path, video_sub_dir) 
                    if os.path.isdir(video_ts_path):
                        
                        video_sub_dir_split_items = video_sub_dir.split('_')
                        video_sub_id = video_sub_dir_split_items[1]
                        video_2_path_dict[video_sub_id] = video_dir + "/" + video_sub_dir + ".ts"
                        
                        video_ts_list = os.listdir(video_ts_path)
                        ts_2_path_dict = {}
                        for video_ts in video_ts_list:
                            if not video_ts.startswith(".") and ".ts" in video_ts:
                                video_ts_split_items = video_ts.split('.')
                                video_ts_id = video_ts_split_items[0]
                                ts_2_path_dict[video_ts_id] = video_dir + "/" + video_sub_dir + "/" + video_ts
                        
                        # 1、拼接部分视频
                        
                        # ts_2_path_dict 按照名称排序
                        ts_2_path_list= sorted(ts_2_path_dict.items(), key=lambda d: int(d[0]))
                        log(ts_2_path_list)

                        # concat 参数
                        ts_param = "concat:"
                        is_first = True
                        for ts_2_path in ts_2_path_list:
                            if is_first:
                                is_first = False
                                ts_param = ts_param + ts_2_path[1]
                            else:
                                ts_param = ts_param + "|" + ts_2_path[1]
                        log(ts_param)

                        # ffmpeg 参数
                        if ts_param != "concat:":
                            
                            ffmpeg_cmd = "ffmpeg -y -i \"" + ts_param + "\" -c copy " + video_dir + "/" + video_sub_dir + ".ts"
                            
                            # run
                            os.system(ffmpeg_cmd)
                        
            # 2、拼接总视频
            # ts_2_path_dict 按照名称排序
            video_2_path_list= sorted(video_2_path_dict.items(), key=lambda d: int(d[0]))
            log(video_2_path_list)

            # concat 参数
            video_param = "concat:"
            is_video_first = True
            for video_2_path in video_2_path_list:
                if is_video_first:
                    is_video_first = False
                    video_param = video_param + video_2_path[1]
                else:
                    video_param = video_param + "|" + video_2_path[1]
            log(video_param)

            # ffmpeg 参数
            if video_param != "concat:":
                
                video_ffmpeg_cmd = "ffmpeg -y -i \"" + video_param + "\" -c copy " + video_dir + "/" + video_dir + ".mp4"
                
                # run
                os.system(video_ffmpeg_cmd)

            # 3、删掉临时文件
            for video_2_path in video_2_path_list:
                os.remove(video_2_path[1])
            
            
            
main()



