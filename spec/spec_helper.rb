require 'pp'
require 'pathname'
require 'rubygems'
require 'spec'
require 'fileutils'

# for __DIR__
require Pathname(__FILE__).dirname.expand_path.parent + 'lib/data_mapper/support/kernel'

ROOT_DIR            = __DIR__.parent
INTEGRATION_DB_PATH = __DIR__ + 'integration/integration_test.db'
FileUtils.touch INTEGRATION_DB_PATH

ENV['LOG_NAME'] = 'spec'
require ROOT_DIR + 'environment'
require __DIR__ + 'lib/mock_adapter'


class Article
  include DataMapper::Resource

  property :id,         Fixnum, :serial => true
  property :blog_id,    Fixnum
  property :created_at, DateTime
  property :author,     String
  property :title,      String

  class << self
    def property_by_name(name)
      properties(repository.name)[name]
    end
  end
end

class Comment
  include DataMapper::Resource
end

class NormalClass
  # should not include DataMapper::Resource
end

# ==========================
# Used for Association specs
class Vehicle
  include DataMapper::Resource

  property :id, Fixnum, :serial => true
  property :name, String
end

class Manufacturer
  include DataMapper::Resource

  property :id, Fixnum, :serial => true
  property :name, String
end

class Supplier
  include DataMapper::Resource

  property :id, Fixnum, :serial => true
  property :name, String
end

class Class
  def publicize_methods
    klass = class << self; self; end

    saved_private_class_methods      = klass.private_instance_methods
    saved_protected_class_methods    = klass.protected_instance_methods
    saved_private_instance_methods   = self.private_instance_methods
    saved_protected_instance_methods = self.protected_instance_methods

    self.class_eval do
      klass.send(:public, *saved_private_class_methods)
      klass.send(:public, *saved_protected_class_methods)
      public(*saved_private_instance_methods)
      public(*saved_protected_instance_methods)
    end

    begin
      yield
    ensure
      self.class_eval do
        klass.send(:private, *saved_private_class_methods)
        klass.send(:protected, *saved_protected_class_methods)
        private(*saved_private_instance_methods)
        protected(*saved_protected_instance_methods)
      end
    end
  end
end
