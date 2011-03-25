module Ananke
  class << self
    attr_accessor :settings
  end

  private

  @settings = {
      :output       => true,
      :info         => true,
      :warning      => true,
      :error        => true,

      :links        => true,
      :remove_empty => false,
      :repository   => 'Repository'
  }

  public

  def repository
    @settings[:repository].to_sym
  end

  def set(name, val)
    @settings[name] = val
  end
end