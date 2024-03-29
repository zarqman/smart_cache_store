require_relative "lib/smart_cache_store/version"

Gem::Specification.new do |spec|
  spec.name        = "smart_cache_store"
  spec.version     = SmartCacheStore::VERSION
  spec.authors     = ["thomas morgan"]
  spec.email       = ["tm@iprog.com"]
  spec.homepage    = "https://github.com/zarqman/smart_cache_store"
  spec.summary     = "Production-ready enhancements for mem_cache_store and redis_cache_store"
  spec.description = "Production-ready enhancements for mem_cache_store and redis_cache_store. For Rails or ActiveSupport."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/zarqman/smart_cache_store/blob/master/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  spec.add_dependency "activesupport", ">= 6.1"
  spec.add_dependency "connection_pool", ">= 2.2.4"
end
