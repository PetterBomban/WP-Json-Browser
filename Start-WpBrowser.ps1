function Start-WpBrowser($Page = 1)
{
    while(1)
    {
        $Api = "https://ITNA.no/wp-json/wp/v2"
        Get-WpPost -Api $Api -Page $Page |
            Show-WpPostTitles -CurrPage $Page |
                Show-WpPostContent -Page $Page
    }
}

function Get-WpPost($Api, $Page)
{
    if ($Page) { $Uri = "$Api/posts?page=$Page" }
    else { $Uri = "$Api/posts" }
    $Result = Invoke-RestMethod -Uri $Uri -Method Get
    $Collection = New-Object System.Collections.ArrayList
    $Collection.Add($Result)
    $Collection
}

function Show-WpPostTitles()
{
    param
    (
        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias("title")]
        $Titles,
        $CurrPage = 1
    )

    ## Creating menu entries per post 
    for ($i=1; $i -le $Titles.Count; $i++ )
    {
        Write-Host "$i) $($Titles[$i-1].title.rendered)"
    }

    Write-Host "11) Next page"
    Write-Host "12) Previous page"
    $Selected = Read-Host -Prompt "Select"
    Clear-Host

    if ($Selected -eq 11) { Start-WpBrowser -Page ($CurrPage + 1) }
    elseif ($Selected -eq 12) { Start-WpBrowser -Page ($CurrPage - 1) }
    $Titles[$Selected - 1]
}

function Show-WpPostContent()
{
    param
    (
        [Parameter(
            ValueFromPipeline = $True
        )]
        $Post,
        $Page
    )

    Write-Host "$($Post.title.rendered)"
    Write-Host "---------- `r`n"

    ## Stripping tags and other unwanted stuff
    $Content = $Post.content.rendered `
        -replace "<[^>]+>", "" `
        -replace "`r`n", "`r`n`r`n" `
        -replace "&nbsp;", " " `
        -replace "&laquo;", "<<" `
        -replace "&raquo;", ">>"

    Write-Host $Content

    Write-Host "1) Open link"
    Write-Host "2) Go back"
    $Selected = Read-Host -Prompt "Select"

    switch ($Selected)
    {
        "1" { Start-Process $Post.link }
        "2" { Clear-Host }
    }
    Start-WpBrowser -Page ($CurrPage)
}

Start-WpBrowser