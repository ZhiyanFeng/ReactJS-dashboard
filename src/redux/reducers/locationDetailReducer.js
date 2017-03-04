const locationDetailReducer = (state = {
    locationDetail: {}

}, action)=>{
    switch (action.type){
        case "SET_LOCATION_DETAIL":
            state = {
                locationDetail: action.locationDetail
            };
            break;
    }
    return state;

}

module.exports = {
    locationDetailReducer,
}
