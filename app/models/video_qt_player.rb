module QtPlayer
  def prepare_recording
prep = <<ENDOT
do shell script "defaults write com.apple.QuickTimePlayerX NSNavLastRootDirectory ~/Desktop"

tell application "QuickTime Player"
close every document
new movie recording
end tell
ENDOT
    system "osascript -e '#{prep}'"
  end
  def start_recording
start = <<ENDOT
tell application "QuickTime Player"
start every document
activate
end tell
ENDOT
    system "osascript -e '#{start}'"
  end
  def stop_recording
stop = <<ENDOT
tell application "QuickTime Player"
try
	stop every document
	set y to name of first document
	y
on error
	return "error"
end try
end tell
ENDOT
    `osascript -e '#{stop}'`.chomp.gsub(' ', '\ ')
  end

end