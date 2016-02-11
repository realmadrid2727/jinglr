class AddTrackToJingles < ActiveRecord::Migration
  def change
    add_attachment :jingles, :track
    add_column     :jingles, :original_track_duration, :float
    add_column     :jingles, :track_duration, :float, default: 0
  end
end
