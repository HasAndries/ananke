module Ananke
  def build_links(link_list, link_to_list, path, id, repository)
    return if !Ananke.settings[:links]

    links = id ? build_link_self(path, id) : []
    links += build_link_list(path, id, repository, link_list)
    links += build_link_to_list(path, id, link_to_list)

    links
  end
  #===========================SELF===============================
  def build_link_self(path, id)
    uri = "/#{path.to_s}"
    uri << "/#{id}" if id
    [{:rel => 'self', :uri => uri}]
  end
  #===========================LINKED=============================
  def build_link_list(path, id, repository, link_list)
    links = []
    link_list.each do |link|
      repository_method = "#{link[:rel]}_id_list"
      if repository.respond_to?(repository_method)
        id_list = repository.send(repository_method, id)
        links = id_list.collect{|i| {:rel => "#{link[:rel]}", :uri => "/#{link[:rel]}/#{i}"}}
      else
        out :error, "#{path} - #{repository} does not respond to '#{repository_method.to_s}'"
      end
    end
    links
  end
  #===========================LINK_TO============================
  def build_link_to_list(path, id, link_to_list)
    link_to_list.collect { |link| {:rel => "#{link[:rel]}", :uri => "/#{link[:rel]}/#{path.to_s.split('/')[0]}/#{id}"} }
  end
end