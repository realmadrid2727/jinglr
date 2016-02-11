module Extends::TagScope
  def Jingle.tag_most_likes(tags, start_at, end_at)
    tagged_with(tags).date_range(start_at, end_at).sort_by do |j|
      j.likes.count
    end.reverse
  end
  
  def Jingle.tag_most_favorites(tags, start_at, end_at)
    tagged_with(tags).date_range(start_at, end_at).sort_by do |j|
      j.favorites.count
    end.reverse
  end
end