import axios from "axios"
const instance = axios.create({
    // baseURL:"http://backend:8000/api"
    baseURL: "/api"   // Relative URL → nginx sẽ proxy đến backend:8000

})
export default instance