const dashboardReducer = (state = {
    dashboardData: []

}, action)=>{
    switch (action.type){
        case "SET_DASHBOARD_DATA":
            state = {
                dashboardData: action.dashboardData.data
            };
            break;
    }
    return state;

}

module.exports = {
    dashboardReducer,
}
