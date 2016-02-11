class JingleMerge < ActiveRecord::Base
  include Extends::NotificationJingle
  include PublicActivity::Model
  
  # If a user owns a merge, that means they took other tracks and merged them
  belongs_to :user, foreign_key: "merged_by_user_id"
  belongs_to :child_jingle, class_name: "Jingle", foreign_key: "child_jingle_id"
  belongs_to :parent_jingle, class_name: "Jingle", foreign_key: "parent_jingle_id"
  
  MERGE_STATE = {
    'merge' => 1,
    'decline' => -1,
    'pending' => 0
  }
  
  tracked
  
  after_save :notify_followers_if_necessary
  
  # Helps out with notification_jingle (parent is jingle)
  def jingle
    parent_jingle
  end
  
  # Helps out with notification_jingle (child adder is user)
  def user_id
    child_jingle.user_id
  end
  
  # Notifies followers of the jingle that a merge was made
  def notify_followers_if_necessary
    if state == MERGE_STATE['merge']
      notify_followers(jingle.id, child_jingle.user.id)
    end
  end
  
  class << self
    # Checks for the existence of a state between two jingles.
    # Options are 'merge', 
    def check_for(term = "merge", jingle1, jingle2)
      jingle1 = Jingle.find(jingle1) if jingle1.is_a?(Integer)
      jingle2 = Jingle.find(jingle2) if jingle2.is_a?(Integer)
      
      if term.split(",").length > 1
        state = ""
        term.split(",").each {|t| state += "state = #{MERGE_STATE[t]} OR "}
        state.chop!.chop!.chop! # Remove the last 3 characters... yeah.
      else
        state = "state = #{MERGE_STATE[term]}"
      end
      
      where(
        "(parent_jingle_id = #{jingle1.id} AND child_jingle_id = #{jingle2.id}) OR " +
        "(parent_jingle_id = #{jingle2.id} AND child_jingle_id = #{jingle1.id})) AND (#{state}"
      ).length > 0
    end
    
    
    # Out of a set of JingleMerge objects, return the one with the highest offset of the supplied type
    def highest_offset_id(array, kind)
      highest_offset = 0
      highest = nil
      
      array.each do |m|
        if highest_offset > m.send((kind.to_s+"_offset").to_sym)
          highest_offset = highest_offset
        else
          highest_offset = m.send((kind.to_s+"_offset").to_sym)
          highest = m.send((kind.to_s+"_jingle").to_sym)
        end
      end
      return {offset: highest_offset, jingle: highest}
    end
  end
end
