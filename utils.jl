using Dates

function tag_badge(tag_name)
    tag_link = "/tag/$(tag_name)"

    """
    <a href="$(tag_link)">
      <span class="blog-tag badge rounded-pill bg-light text-dark">
        $(tag_name)
      </span>
    </a>"""
end

function hfun_postcard(params)
    page_rpath = strip(params[1], ['/', '"'])

    title = pagevar(page_rpath, "title")
    description = pagevar(page_rpath, "desc")
    tags = pagevar(page_rpath, "tags")
    date = pagevar(page_rpath, "date")
    formatted_date = "$(dayname(date)), $(monthabbr(date)) $(day(date)), $(year(date))"
    link = "/" * page_rpath
    image = length(params) ≥ 2 ?
        """<img class="card-img-top" src="$(params[2])" />""" :
        ""#"<div class="card-img-top" style="background-color: blue"></div>"""

    tag_html = join(tag_badge.(tags), "\n")

    """
    <div class="post-card card bg-dark text-white border-light mb-4">
        $(image)
        <div class="card-body">
            <a href="$(link)"><h2 class="card-title">$(title)</h2></a>
            <small class="posted-date card-text">$(formatted_date)</small>
            <p class="card-text mt-3">$(description) &nbsp;&nbsp;<a href="$(link)" class="read-more">Read More</a></p>
            $(tag_html)
        </div>
    </div>
    """
end
