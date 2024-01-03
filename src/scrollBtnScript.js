document.addEventListener("DOMContentLoaded", function () {
    var btn = document.getElementById("button");

    window.onscroll = function () {
        if (document.body.scrollTop > 300 || document.documentElement.scrollTop > 300 || window.scrollY > 300) {
            btn.classList.add("show");
        } else {
            btn.classList.remove("show");
        }
    };

    btn.addEventListener("click", function (e) {
        e.preventDefault();
        document.body.scrollTop = 0; // For Safari
        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE, and Opera
        window.scrollY = 0;
    });

    var toggleButton = document.getElementById('see_more');
    var hiddenRows = document.querySelectorAll('.hiddenRow');

    toggleButton.addEventListener('click', function() {
        hiddenRows.forEach(function(row) {
          if(row.style.display === 'none'){
            row.style.display = 'table-row';
            toggleButton.textContent = toggleButton.dataset.text_less;
          }
          else{
           row.style.display = 'none';
           toggleButton.textContent = toggleButton.dataset.text_more;
          }
        });
      });
});