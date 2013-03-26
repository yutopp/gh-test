module Jekyll
  class ContentMapGenerator < Generator
    safe true
    
    def generate(site)
      site.config['drj_content_map'] = Hash.new
      
      # probe root
      site.config['drj_content_map'][''] = Hash.new
      site.config['drj_content_map']['']['_child'] = Hash.new
      site.config['drj_content_map']['']['_child']['index'] = Hash.new
      site.config['drj_content_map']['']['_child']['index']['title'] = "Home"
      site.config['drj_root'].each do |root, value|
        #p "=> #{get_title(root, site.source)}"
        probe_child( site.config['drj_content_map']['']['_child'], root, site.source )
      end
      
      
      #
      site.config['drj_content_map_for_root'] = Hash.new
      site.config['drj_content_map_for_root'][''] = Hash.new
      site.config['drj_content_map_for_root']['']['title'] = "Home"
      site.config['drj_root'].each do |root, value|
        title = get_title( nil, "#{site.source}/#{root}/index.md" ) || get_title( nil, "#{site.source}/#{root}/index.html" ) || nil
        next if title.nil?
        
        site.config['drj_content_map_for_root'][root] = Hash.new
        site.config['drj_content_map_for_root'][root]['title'] = title
        #probe_child( site.config['drj_content_map']['']['_child'], root, site.source )
      end
      
      #p site.config['drj_content_map_for_root']
    end
    
    private
    def probe_child( map, key, dir )
      map[key] = Hash.new if map[key].nil?
      map[key]['_child'] = Hash.new if map[key]['_child'].nil?
      
      Dir::entries("#{dir}/#{key}")
        .select{|p| p != '.' && p != '..' }
        .each do |e|
        entry = File.basename(e, ".*")

        #p e
        if File::ftype("#{dir}/#{key}/#{e}") == 'directory'
          probe_child( map[key]['_child'], e, "#{dir}/#{key}" )
        else
          map[key]['_child'][entry] = Hash.new
          map[key]['_child'][entry]['title'] = get_title( e, "#{dir}/#{key}/#{e}" )
        end

      end
      
    end
    
    private
    def get_title( default_val, path )
      title = default_val
      content = File.read( path )
      reg = /^(---\s*\n(.*?\n?))^(---\s*$\n?)/m
      if content =~ reg
        record = content.split(reg)
        hash_map = YAML.load(record[2]) || {}
        title = hash_map['title'] unless hash_map['title'].nil?
      end

      return title
    end
    
  end # class ContentMapGenerator
end # module Jekyll
