module Jekyll
  class APIMapGenerator2 < Generator
    safe true
    
    def generate(site)
      # api library list
      site.config['drj_api_map'] = Hash.new
      Dir::entries("#{site.source}#{site.config['drj_api_ref']}")
        .select{|p| File::ftype("#{site.source}#{site.config['drj_api_ref']}/#{p}") == 'directory' }
        .select{|p| p != '.' && p != '..' }
        .each do |lib_name|
        #
        site.config['drj_api_map'][lib_name] = Array.new
        
        # entry type
        Dir::entries("#{site.source}#{site.config['drj_api_ref']}/#{lib_name}")
          .select{|p| File::ftype("#{site.source}#{site.config['drj_api_ref']}/#{lib_name}/#{p}") == 'directory' }
          .select{|p| p != '.' && p != '..' }
          .each do |entry_type|
          
          Dir::entries("#{site.source}#{site.config['drj_api_ref']}/#{lib_name}/#{entry_type}")
            .select{|p| File::ftype("#{site.source}#{site.config['drj_api_ref']}/#{lib_name}/#{entry_type}/#{p}") == 'file' }
            .select{|p| p != '.' && p != '..' }
            .each do |entry_name|
            
            site.config['drj_api_map'][lib_name] << {"type" => entry_type, "name" => File.basename(entry_name, ".*") }
          end
        end
        
        #p site.config['drj_api_map']
      end
    end
    
  end # class APIMapGenerator2
end # module Jekyll
