const adminClaimReducer = (state = {
    info: [],
}, action)=>{
    switch (action.type){
        case "SET_SEARCH_ADMIN_CLAIM":
            state = {
                info: action.info.admin_claim_info
            };
            break;
    }
    return state;

}

module.exports = {
    adminClaimReducer,
}
