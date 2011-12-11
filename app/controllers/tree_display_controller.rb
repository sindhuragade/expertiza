class TreeDisplayController < ApplicationController
  helper :application

  #session variables used here
  #session[:course_rubrics] : indicates if we are viewing course related rubrics
  #session[:question_naire] : indicates if we are going to the questionnaires page from the manage menu
  #session[:choice] : indicates if we need to filter the assignments. 0 indicates No. 1 indicates Yes
  #session[:question] : indicates if we need to filter the questionnaires. 0 indicates No. 1 indicates Yes


  # direct access to questionnaires
  def goto_questionnaires
    session[:question_naire]=1
    node_object = TreeFolder.find_by_name('Questionnaires')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end


  def goto_course_related_questionnaires
    session[:course_rubrics]=params[:id]
    node_object = TreeFolder.find_by_name('Questionnaires')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end


  
  # direct access to review rubrics
  def goto_review_rubrics
    node_object = TreeFolder.find_by_name('Review')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to metareview rubrics
  def goto_metareview_rubrics
    node_object = TreeFolder.find_by_name('Metareview')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end   
  
  # direct access to teammate review rubrics
  def goto_teammatereview_rubrics
    node_object = TreeFolder.find_by_name('Teammate Review')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end   
  
  # direct access to author feedbacks
  def goto_author_feedbacks
    node_object = TreeFolder.find_by_name('Author Feedback')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to global survey
  def goto_global_survey
    node_object = TreeFolder.find_by_name('Global Survey')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to surveys
  def goto_surveys
    node_object = TreeFolder.find_by_name('Survey')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to course evaluations
  def goto_course_evaluations
    node_object = TreeFolder.find_by_name('Course Evaluation')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end    
  
  # direct access to courses
  def goto_courses
    node_object = TreeFolder.find_by_name('Courses')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end
  
  # direct access to assignments
  def goto_assignments
    session[:choice]=0
    session[:assignment]=1
    node_object = TreeFolder.find_by_name('Assignments')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  

  #filters the assignments when requested for only assignments that are not related to any course
  def assignments_filter
  copy_child_nodes=Array.new
                assignment_array=Array.new
                seen={}
                #filtering the @child_nodes array
                for assignments in @child_nodes
                              assignment_array=Assignment.find_all_by_name(assignments.get_name)
                              #copy all assignments whose course_id's are null into a new array
                              for each_assignment in assignment_array
                                      key=[each_assignment.name]
                                      if  !seen.has_key?(key)
                                           if each_assignment.course_id.nil?
                                                    seen[key]=1
                                                    copy_child_nodes << assignments
                                           end
                                      end
                              end
                end
                @child_nodes=Array.new
                #copy back into the @child_nodes array
                for assignments in copy_child_nodes
                      @child_nodes << assignments
                end
  end

  #filters the rubrics when asked for non assignment related rubrics
  def rubrics_filter
    questionnaire_ids = Array.new
    questionnaires_array = Array.new
    filtered_rubrics = Array.new

                           assignments_by_instructor = Assignment.find_all_by_instructor_id(session[:user].id)
                           for assignments in assignments_by_instructor
                                questionnaire_ids << AssignmentQuestionnaires.find_all_by_assignment_id(assignments.id)
                           end
                           #get all questionnaires associated with this instructors assignments
                           seen={}
                           for questionnaire in questionnaire_ids
                              for temp_value in questionnaire
                                  key=[Questionnaire.find_by_id(temp_value.questionnaire_id).name]
                                  if !seen.has_key?(key)
                                        questionnaires_array << Questionnaire.find_by_id(temp_value.questionnaire_id).name
                                        seen[key]=1
                                  end
                              end
                           end
                           #filter the @child_nodes array
                           seen={}
                           for assignments in @child_nodes
                                  #check if this rubric is present in the list of rubrics associated with assignments
                                  for questionnaire in questionnaires_array
                                         if questionnaire==assignments.get_name
                                                flag1=1
                                         end
                                  end
                                  #if not present
                                  if flag1!=1
                                      key=[assignments.get_name]
                                      if !seen.has_key?(key)
                                           filtered_rubrics << assignments
                                           seen[key]=1
                                      end
                                  end
                           end

                           @child_nodes=Array.new
                                for rubric in filtered_rubrics
                                    @child_nodes << rubric
                           end
  end

  #filters rubrics as per the course selected
  def course_rubrics_filter
    questionnaires_array = Array.new
    questionnaire_ids = Array.new

            course_related_assignments = Assignment.find_all_by_course_id(session[:course_rubrics])

            for assignments in course_related_assignments
              # temp=Assignment.find(a).instructor_id;
               #if(temp==session[:user].id)
                      questionnaire_ids << AssignmentQuestionnaires.find_all_by_assignment_id(assignments.id)
              # end
            end

            #all questionnaires related to course
            for questionnaire in questionnaire_ids
              for each_questionnaire in questionnaire
               @child_nodes << Questionnaire.find_by_id(each_questionnaire.questionnaire_id)
                puts Questionnaire.find_by_id(each_questionnaire.questionnaire_id).name
              end
            end

  end



  # called when the display is requested
  # ajbudlon, July 3rd 2008
  def list  

    if session[:display]
      @sortvar = session[:display][:sortvar]
      @sortorder = session[:display][:sortorder]
      if session[:display][:check] == "1"
        @show = nil
      else
        @show = true
      end
    end
    if params[:display]      
      @sortvar = params[:display][:sortvar]
      @sortorder = params[:display][:sortorder] 
      if params[:display][:check] == "1"
        @show = nil
      else
        @show = true
      end
      session[:display] = params[:display]      
    end
  
    if session[:display].nil? and params[:display].nil?
      @show = true
    end
    
    if @sortvar == nil
      @sortvar = 'created_at'
    end
    if @sortorder == nil
      @sortorder = 'desc'
    end

    if params[:display]
      session[:choice]=params[:display][:choice].to_i
      session[:question]=params[:display][:question].to_i
    end


    if session[:root]
            @root_node = Node.find(session[:root])
            @child_nodes = @root_node.get_children(@sortvar,@sortorder,session[:user].id,@show)
    else
            @child_nodes = FolderNode.get()
    end

    if session[:root]==nil
      session[:trial]=nil
      session[:filter_questionnaires]=0
    end

    if session[:root].to_i!=3
      session[:assignment]=0
    end

    if session[:root].to_i!=1
      session[:question_naire]=0
    end

    if session[:root]==nil || session[:question_naire]==1
      session[:course_rubrics]=nil
    end

    #if we are in the assignments page and the choice is to show only assignments not related to any course
    if session[:root] && Node.find(session[:root]).node_object_id!=nil && Node.find(session[:root]).node_object_id==3 && session[:choice].to_i==1
                @show_assign=nil
                assignments_filter
    else
      @show_assign=true
    end

  #if inside the questionnaires page, set the session variable according to whether we need to show or only questionnaires not associated to any assignment
  if session[:root] && Node.find(session[:root]).node_object_id!=nil && Node.find(session[:root]).node_object_id==1 && session[:question].to_i==1
     @show_question=nil
     session[:filter_questionnaires]=1
  else
      @show_question=true

  end

  #display all questionnaires
  if  session[:question].to_i!=1
          session[:filter_questionnaires]=0
  end

  #when we drill down into any of the rubrics in questionnaires display accordingly
  if session[:filter_questionnaires]==1  && session[:course_rubrics]==nil
                if session[:root] && Node.find(session[:root]).node_object_id!=nil && Node.find(session[:root]).node_object_id!=1
                    rubrics_filter
                end
  end


    #course_related rubrics
    if session[:course_rubrics] && session[:root]  && session[:question_naire]!=1
          course_rubrics_filter
    end






end





  def drill

        session[:root] = params[:root]

        #if we are in the assignments page set the corresponding session variables
        if session[:root] && Node.find(session[:root]).node_object_id!=nil && Node.find(session[:root]).node_object_id==3
            session[:assignment]=1
            session[:choice]=0
        end

        #when we are in the questionnaires page set corresponding session variables
        if session[:root] && Node.find(session[:root]).node_object_id!=nil && Node.find(session[:root]).node_object_id==1
            session[:question_naire]=1
        end

    redirect_to :controller => 'tree_display', :action => 'list'
  end
end
