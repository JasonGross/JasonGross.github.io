
%   <tr>
%     <td><img src="drawing_videos/char9_Tagalog_images_small.jpg" width="390" height="417"></td>
%     <td>
% 	<video width="390" height="417" controls>
% 	 <source src="drawing_videos/char9_Tagalog_high.mp4"  type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"'>
% 	 <source src="drawing_videos/char9_Tagalog_high.theora.ogg"  type='video/ogg; codecs="theora, vorbis"'>
% 	</video>
% 	</td>
%   </tr>

function make_character_videos
    
    dr = 'drawing_videos';
    files = inspect_dir(dr);
    nfiles = length(files);
    
    % Get all the unique base names
    unique_base = [];
    stop_str = {'_images','_high','_strokes'};
    for i=1:nfiles
        fn = files{i};    
        fn_base = [];
        for j=1:length(stop_str)
            indxj = strfind(fn,stop_str{j});
            if ~isempty(indxj)
               fn_base = fn(1:indxj-1);
            end
        end
        assert(~isempty(fn_base) || isequal(fn,'key.jpg'));
        if ~isempty(fn_base)
            unique_base = unique([unique_base; {fn_base}]); 
        end
    end
    
       
    nunique = length(unique_base);
    fid = fopen('table.txt','w');
    for i=1:nunique
        bn = unique_base{i};
        fprintf(fid,'  <tr>\n');
        
        img = [bn,'_images_small.jpg'];
        vid_mp4 = [bn,'_high.mp4'];
        vid_ogg = [bn,'_high.theora.ogg'];
        
        fprintf(fid,'    <td><img src="drawing_videos/%s" width="390" height="417"></td>\n',img);
        fprintf(fid,'    <td>\n');
        fprintf(fid,'    <video width="390" height="417" controls>\n');
        fprintf(fid,'      <source src="drawing_videos/%s"  type=''video/mp4; codecs="avc1.42E01E, mp4a.40.2">''',vid_mp4);
        fprintf(fid,'      <source src="drawing_videos/%s"  type=''video/ogg; codecs="theora, vorbis"''>',vid_ogg);
        fprintf(fid,'    </video>\n');
        fprintf(fid,'    </td>\n');
        fprintf(fid,'  </tr>\n');        
    end
    fclose(fid);    
end