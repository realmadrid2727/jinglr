class JingleOrigin < ActiveRecord::Base
  include PublicActivity::Model
  
  # This model is used to tie together the merging of already-existing tracks
  belongs_to :parent, class_name: "Jingle", foreign_key: "parent_id" # Owner
  belongs_to :jingle, class_name: "Jingle", foreign_key: "jingle_id" # Jingle to merge to owner
  
  tracked
end
