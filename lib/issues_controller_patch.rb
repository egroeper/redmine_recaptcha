module IssuesControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :create, :recaptcha_verification
      alias_method_chain :update, :recaptcha_verification
    end
  end
  
  module InstanceMethods
    def create_with_recaptcha_verification
      call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
      IssueObserver.instance.send_notification = params[:send_notification] == '0' ? false : true
      if (User.current.logged? || verify_recaptcha( :private_key => Setting.plugin_redmine_recaptcha['recaptcha_private_key'], :model => @user, :message => "There was an error with the recaptcha code below. Please re-enter the code and click submit." )) && @issue.save
        attachments = Attachment.attach_files(@issue, params[:attachments])
        render_attachment_warning_if_needed(@issue)
        flash[:notice] = l(:notice_successful_create)
        call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
        respond_to do |format|
          format.html {
            redirect_to(params[:continue] ?  { :action => 'new', :project_id => @project, :issue => {:tracker_id => @issue.tracker, :parent_issue_id => @issue.parent_issue_id}.reject {|k,v| v.nil?} } :
                        { :action => 'show', :id => @issue })
          }
          format.api  { render :action => 'show', :status => :created, :location => issue_url(@issue) }
        end
        return
      else
        respond_to do |format|
          format.html { render :action => 'new' }
          format.api  { render_validation_errors(@issue) }
          format.api  { render_validation_errors(@user) }
        end
      end
        #the old method is accessible here:
        #create_without_recaptcha_verification
    end

    def update_with_recaptcha_verification
      update_issue_from_params
      JournalObserver.instance.send_notification = params[:send_notification] == '0' ? false : true
      if (User.current.logged? || verify_recaptcha( :private_key => Setting.plugin_redmine_recaptcha['recaptcha_private_key'], :model => @user, :message => "There was an error with the recaptcha code below. Please re-enter the code and click submit." )) && @issue.save_issue_with_child_records(params, @time_entry)
        render_attachment_warning_if_needed(@issue)
        flash[:notice] = l(:notice_successful_update) unless @issue.current_journal == @journal
  
        respond_to do |format|
          format.html { redirect_back_or_default({:action => 'show', :id => @issue}) }
          format.api  { head :ok }
        end
      else
        render_attachment_warning_if_needed(@issue)
        flash[:notice] = l(:notice_successful_update) unless @issue.current_journal == @journal
        @journal = @issue.current_journal
  
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.api  { render_validation_errors(@issue) }
        end
      end
          
        #the old method is accessible here:
        #update_without_recaptcha_verification
    end
  end
end
