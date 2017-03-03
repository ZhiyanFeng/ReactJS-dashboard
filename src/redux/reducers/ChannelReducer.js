const channelReducer = (state = {
    channels: []

}, action)=>{
    switch (action.type){
        case "SET_REGION_CHANNEL":
            state = {
                channels: Array.from(action.channels)
            };
            break;
    }
    return state;

}

module.exports = {
    channelReducer,
}
