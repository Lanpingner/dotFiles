function copyenvrc
    set source_file /home/romeo/Templates/envrc_python_venv
    set dest_file ".envrc"

    if not test -e $source_file
        echo "Error: Template file '$source_file' not found!"
        return 1
    end

    cp "$source_file" "$PWD/$dest_file"
    echo "Copied '$source_file' to '$PWD/$dest_file'"
end
