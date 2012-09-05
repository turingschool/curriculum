var JSTasker = {
  update_task_counter: function() {
    var task_count = $('div#tasks ul').children().not('li.completed').size();
    $('span#task_counter').text(task_count);
  },
  sort_tasks: function() {
    var task_list = $('div#tasks ul');
    var all_completed = task_list.children('li.completed');
    all_completed.detach();
    all_completed.appendTo(task_list);
  },
  update_page: function (){
    this.update_task_counter();
    this.sort_tasks();
  }
};

$(function(){
  $('input#task_text').focus();
  $('input#add_button').click(function(event){
    event.preventDefault();
    //var task_text = $('input#task_text').val();
    //var task_item = $('<li>' + task_text + '</li>');
    //task_item.click(function (){
    //  $(this).toggleClass('completed');
    //  JSTasker.update_page();
    //});

    //$('div#tasks ul').append(task_item);
    //$('input#task_text').val(null);
    //JSTasker.update_page();

    var text = $('input#task_text').val();
    if(text != ''){
      var new_item = $("<li>" + text + "<img class='trash' src='icons/bin.png' /></li>");
      $('div#tasks ul').prepend(new_item.fadeIn());
      JSTasker.update_task_counter();
      new_item.click(function (){
        new_item.toggleClass('completed');
        JSTasker.update_task_counter();
        $('input#task_text').focus();
      });

      new_item.children('img').click(function(){
        new_item.unbind('click');
        new_item.fadeOut('slow', JSTasker.update_task_counter);
        $('input#task_text').focus();
      });

      $('input#task_text').val('');
      $('input#task_text').focus();
    };
  });
});
