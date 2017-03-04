const locationReducer = (state = {
    locations: []

}, action)=>{
    switch (action.type){
        case "SET_SEARCH_LOCATIONS":
            state = {
                locations: Array.from(action.locations)
            };
            break;
    }
    return state;

}

module.exports = {
    locationReducer,
}
