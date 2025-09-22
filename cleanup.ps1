# Define the directory path
$directoryPath = "/Users/dalehassinger/Documents/GitHub/stack/themes/stack/vcrocs/content/post"

# Get all index.en.md files recursively (use -Recurse without -Name to get full FileInfo objects)
$files = Get-ChildItem -Path $directoryPath -Filter "index.en.md" -Recurse

foreach ($file in $files) {
    $filePath = $file.FullName
    Write-Host "Processing: $filePath"
    
    # Read the file content
    $content = Get-Content -Path $filePath -Raw
    
    # Remove lines with specific text
    $content = $content -replace '(?m)^.*weight:\s*1.*$\r?\n?', ''
    $content = $content -replace '(?m)^.*lastmod:.*$\r?\n?', ''
    $content = $content -replace '(?m)^.*authorLink:.*$\r?\n?', ''
    $content = $content -replace '(?m)^.*images:.*$\r?\n?', ''
    $content = $content -replace '(?m)^.*ightgallery:.*$\r?\n?', ''
    
    # Remove admonition shortcode lines
    $content = $content -replace '(?m)^.*\{\{<\s*/admonition\s*>\}\}.*$\r?\n?', ''
    $content = $content -replace '(?m)^.*admonition type=.*$\r?\n?', ''
    
    # Remove the resources block (multiline)
    $content = $content -replace '(?s)resources:\s*\n\s*name:\s*"featured-image"\s*\n\s*src:\s*"featured-image\.png"\s*\n?', ''
    
    # Add image line after the resources block is removed
    # Look for the front matter section and add the image line
    if ($content -match '(?s)(---.*?---\s*)(.*)') {
        $frontMatter = $matches[1]
        $bodyContent = $matches[2]
        
        # Add image line to front matter if it doesn't exist
        if ($frontMatter -notmatch 'image:') {
            $frontMatter = $frontMatter -replace '(---\s*)$', "image: featured-image.png`n---`n"
        }
        $content = $frontMatter + $bodyContent
    }
    
    # Change date format from ISO to YYYY-MM-DD
    $content = $content -replace 'date:\s*(\d{4}-\d{2}-\d{2})T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}', 'date: $1'
    
    # Remove {{< cusdis >}} lines
    $content = $content -replace '(?m)^.*\{\{<\s*cusdis\s*>\}\}.*$\r?\n?', ''
    
    # Change ###### to ##
    $content = $content -replace '######', '##'
    
    # Remove specific caption text
    $content = $content -replace 'caption="Click to see Larger Image of Screen Shot"', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the PowerShell code:</span></small>', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the yaml code:</span></small>', ''
    $content = $content -replace 'caption="Click to see Larger Image"', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the cli code:</span></small>', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the PowerShell code:</span></small>', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the code:</span></small>', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the JavaScript code:</span></small>', ''
    $content = $content -replace '<span style="color: red; font-weight: bold;">Click arrow to expand the code:</span>', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the cron job code:</span></small>', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the ABX Action PowerShell code:</span></small>', ''
    $content = $content -replace '<small><span style="color: red; font-weight: bold;">Click arrow to expand the cron commands:</span></small>', ''

    $content = $content -replace 'Click arrow to expand the PowerShell Code:', 'PowerShell Code:'
    $content = $content -replace "Click arrow to expand the code:", "Code:"

    # Convert Hugo image shortcodes to markdown for png, jpg, jpeg (but not gif)
    $content = $content -replace '\{\{<\s*image\s+src="([^"]+\.(?:png|jpg|jpeg))"[^}]*\}\}', '![]($1)'
    
    # Write the modified content back to the file
    Set-Content -Path $filePath -Value $content -NoNewline
    
    Write-Host "Completed: $filePath"
}

Write-Host "All files processed successfully!"