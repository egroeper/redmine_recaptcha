module ClientHelperPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :recaptcha_tags, :flash_remove
    end
  end

  module InstanceMethods
    def recaptcha_tags_with_flash_remove(options={})
      html = recaptcha_tags_without_flash_remove( options )
      flash.delete( :recaptcha_error )
      #used to be return html for 0.9 versions. fix identified by Christophe Bourcier (http://www.redmine.org/issues/675#note-32)
      return html.html_safe
    end
  end
end
