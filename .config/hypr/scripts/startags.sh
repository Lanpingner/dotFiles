while true; do
	# Command to start your AGS app
	ags

	# Check if the AGS app process is still running
	if pgrep -f "ags" >/dev/null; then
		echo "AGS app is running."
	else
		echo "AGS app has crashed. Restarting..."
	fi

	# Add a delay before attempting to restart (adjust as needed)
	sleep 5
done
