document.addEventListener("DOMContentLoaded", function () {
    var btn = document.getElementById("button");

    window.onscroll = function () {
        if (document.body.scrollTop > 400 || document.documentElement.scrollTop > 400) {
            btn.classList.add("show");
        } else {
            btn.classList.remove("show");
        }
    };

    btn.addEventListener("click", function (e) {
        e.preventDefault();
        document.body.scrollTop = 0; // For Safari
        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE, and Opera
    });
});