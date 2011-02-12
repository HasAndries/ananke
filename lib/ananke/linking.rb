module Ananke
  def build_links(link_list, link_to_list, path, id, mod)
    return if !Ananke.settings[:links]

    links = build_link_self(path, id)
    links += build_link_list(path, id, mod, link_list)
    links += build_link_to_list(path, id, link_to_list)

    links
  end
  #===========================SELF===============================
  def build_link_self(path, id)
    [{:rel => 'self', :uri => "/#{path}/#{id}"}]
  end
  #===========================LINKED=============================
  def build_link_list(path, id, mod, link_list)
    links = []
    link_list.each do |l|
      mod_method = "#{l[:rel]}_id_list"
      if mod.respond_to?(mod_method)
        id_list = mod.send(mod_method, id)
        id_list.each{|i| links << {:rel => "#{l[:rel]}", :uri => "/#{l[:rel]}/#{i}"}}
      else
        out :error, "#{path} - #{mod} does not respond to '#{mod_method.to_s}'"
      end
    end
    links
  end
  #===========================LINK_TO============================
  def build_link_to_list(path, id, link_to_list)
    links = []
    link_to_list.each do |l|
      links << {:rel => "#{l[:rel]}", :uri => "/#{l[:rel]}/#{path}/#{id}"}
    end
    links
  end
end