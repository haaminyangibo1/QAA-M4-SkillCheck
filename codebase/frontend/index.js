'use strict'

const header = document.querySelector('h1');

// Was: fetch('http://localhost:5000/colour')
// "localhost" means the VISITOR's own computer, where no backend runs.
// "/colour" asks the same server that sent this page (nginx), which
// forwards the request to the backend inside the cluster.
fetch('/colour').then((response) => {
    response.text().then((data) => {
        header.style.color = data;
    })
})
