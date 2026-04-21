const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');

fs.writeFileSync('test_video.mp4', 'dummy content');
const form = new FormData();
form.append('title', 'Test Episode');
form.append('seriesId', '60b8d295f1d2b3001f3d53b9'); // fake id
form.append('video', fs.createReadStream('test_video.mp4'));

axios.post('http://localhost:5000/api/episodes/upload', form, {
    headers: form.getHeaders()
}).then(res => {
    console.log("SUCCESS:", res.data);
}).catch(err => {
    console.error("ERROR:", err.response ? err.response.data : err.message);
});
