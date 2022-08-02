$(document).on("turbolinks:load",function(){ 
  $(document).on("click", "span.comment-options-icon", function(e) {
    let commentOptionsIcon = $(e.currentTarget)
    $(e.currentTarget).css("background-color", "#dedede")
    let commentOptionsContent = commentOptionsIcon.siblings(".comment-options-content")
    commentOptionsContent.show()

    $(document).on('click', function(event) {
      if (!$(event.target).closest(commentOptionsIcon).length) {
        // the click occured outside '#element'
        commentOptionsIcon.css("background-color","")
        commentOptionsContent.hide()
      }        
    });
  });

  $('textarea').on("input", function(e) {
    target = e.currentTarget
    target.style.height = ""
    target.style.height = target.scrollHeight + "px"
  })

  // Add a tag to the new post when click on a tag 
  $(document).on("click", ".avail-tag", function(e) {
    console.log(3)
    e.stopImmediatePropagation()
    let newTag = addNewTag($(this).text())
    $(".post-new-tag-user").before(newTag)
    userTag()
    e.target.remove()
    // Hide list of available tags if number of selected tags is 4
    if ($(".post-new-tag").length == 4) {
      $(".avail-tags-top").text("Only 4 selections allowed")
      $(".avail-tags-top").removeClass("border-bottom")
      $(".avail-tags-body").hide()
    }
  })

  let allTag = [] 
  $(".post-new-tag").each(function(e) {
    allTag.push($(this).children("input").val())
  })
  $(".avail-tag").each(function(e) {
    allTag.push($(this).text())
  })
  console.log(allTag)

  // Delete a tag when click on the X icon 
  $(document).on("click", ".tag-remove-btn", function(e) {
    e.stopImmediatePropagation()
    let tag = $(this).siblings("input").val()
    if (allTag.includes(tag)) { 
      $(".avail-tags-body").append('<div class="avail-tag row mx-auto p-3">' + tag + '</div>')
    }
    $(e.target).closest(".post-new-tag").remove()
    userTag()
    // Show list of tags
    if ($(".avail-tags-body").is(":hidden")) {
      $(".avail-tags-top").text("Top tags")
      $(".avail-tags-top").addClass("border-bottom")
      $(".avail-tags-body").show()
    }
  })

  // Add new tag when user click add btn
  $(document).on("click", ".tag-add-btn", function(e) {
    if ($(this).siblings("input").val().replace(/\s/g,'') == "")
      return
    let newTag = addNewTag($(this).siblings("input").val())
    $(".post-new-tag-user").before(newTag)
    userTag()
    if ($(".post-new-tag-user").length)
      $(this).siblings("input").val("")
  })

  function userTag() {
    if ($(".post-new-tag").length < 4) {
        if (!$(".post-new-tag-user").length) {
          let newTag = 
          '<div class="post-new-tag-user input-group me-1 mb-1">\
            <input class="form-control" type="text" placeholder="New tag">\
            <button class="btn btn-outline-success tag-add-btn" type="button"><i class="fa-solid fa-check"></i></button>\
          </div>'
          $(".tags-holder").append(newTag)
        }
    }
    else {
      $(".post-new-tag-user").remove()
    }
  }

  function addNewTag(tag) {
    let newTag = 
    '<div class="post-new-tag input-group me-1 mb-1">\
      <input class="form-control" type="text" value="' + tag + '">\
      <button class="btn btn-outline-danger tag-remove-btn" type="button"><i class="fa-solid fa-x"></i></button>\
    </div>'
    return newTag
  }

  $("#edit-post-form").on("submit", function() {
    let postTags = ""
    $(".post-new-tag input").each(function() {
      postTags += $(this).val()
    })
    console.log(postTags)
    $("#post_tags").val(postTags)
  })

  $(document).on("focus", ".post-new-tag-user input, .post-new-tag input", function() {
    $(".avail-tags").show()
    console.log(1)
  })
  
  $(document).on("click", ".avail-tags-top", function() {
    if ($(".avail-tags").is(":visible")) {
      $(".avail-tags").hide()
      console.log(2 + " " +this)
    }
  })
  
  if($('#posts').length) {
    $(window).on("scroll", function(){
      if ($(".pagy").length && ($(window).scrollTop() >= $('.pagy').offset().top + $('.pagy').outerHeight() - window.innerHeight)) {
        
        if (!$(".page-item.next").hasClass("disabled")) {
          $(".page-item.next a")[0].click()
        }
      }
    })
  }

  $("#navbar-notif-btn").on("click", function() {
    if ($("#navbar-notif-new").is(":visible")) {
      $("#navbar-notif-new").hide()
    }
  })

})

