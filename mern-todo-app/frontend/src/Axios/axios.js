import axios from "axios"
const instance = axios.create({
    baseURL:"http://backend:8000/api"
})
export default instance