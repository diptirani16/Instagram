function postdata(){

    // console.log("hello");
    var user = document.getElementById("username").value;
    var pass = document.getElementById("password").value;

    fetch("http://localhost:3000/login", {
          method: "POST",
          body: JSON.stringify({ username: user , password:  pass}),
          headers: { "Content-Type": "application/json" },
        })
          .then(function (res) {
            console.log(res);
          })
          .catch(function (res) {
            console.log(res);
          })

}