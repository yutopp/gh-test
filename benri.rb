#!/usr/bin/env ruby

require 'fileutils'

SITE_DIR = '_site'
FOR_GH_DIR = '__deploy'

REPO = 'git@github.com:yutopp/gh-test.git'
REPO_NAME = 'gh-test'

BRANCH_GH_PAGES = 'gh-pages'

Dir.chdir( File.dirname(__FILE__) ) do
  p "at #{Dir.pwd}"
  
  case ARGV[0]
  #
  when 'setup'
    system "rm -rf #{FOR_GH_DIR}"
    Dir.mkdir FOR_GH_DIR
    Dir.chdir( FOR_GH_DIR ) do
      system "git clone #{REPO}"
      Dir.chdir( REPO_NAME ) do
        current_branch = File.basename( `git symbolic-ref HEAD 2> /dev/null` )
        begin
          system "git checkout -B #{BRANCH_GH_PAGES}"
          system "git rm -rf *"
          
          Dir.entries( Dir.pwd ).each do |f|
            FileUtils.remove_entry_secure f unless f == '.git' || f == '.' || f == '..'
          end
          
          FileUtils.touch '.nojekyll'
          
          Dir.entries( Dir.pwd ).each do |f|
            p "-> #{f}"
          end
          
          system "git commit -m \"init\""
          
        ensure
          #system "git checkout #{current_branch}"
        end
      end
    end

  #
  when 'deploy'
    # build
    system 'jekyll'
    src_dir = Dir.pwd + '/' + SITE_DIR
    
    Dir.chdir( FOR_GH_DIR ) do
      Dir.chdir( REPO_NAME ) do
        dst_dir = Dir.pwd
        p "from #{src_dir} -> to #{dst_dir}"
        
        current_branch = File.basename( `git symbolic-ref HEAD 2> /dev/null` )
        begin
          system "git checkout #{BRANCH_GH_PAGES}"
          
          system "git reset"
          system "git rm -rf *"
          
          # copy site data
          Dir.entries( src_dir ).select{|p| p != '.' && p != '..'}.map{|p| "#{src_dir}/#{p}"}.each{|f| p f}
          FileUtils.cp_r( Dir.entries( src_dir ).select{|p| p != '.' && p != '..'}.map{|p| "#{src_dir}/#{p}"}, dst_dir )

          system "git add . -n"
          system "git add ."
          system "git commit -m \"generate\""
          system "git push -f origin #{BRANCH_GH_PAGES}"
          
        ensure
          #system "git checkout #{current_branch}"
        end
      end
    end

  #
  when 'delete'
    system "git push origin :#{BRANCH_GH_PAGES}"
    
  #
  when 'server'
    system "jekyll _dev_site/ --server --url http://localhost:4000"
    
  else
    p "Use -> ./benri (setup|deploy|delete|server)"
    
  end
  
end # chdir
