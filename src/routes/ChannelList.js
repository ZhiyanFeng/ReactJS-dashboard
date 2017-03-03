import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import { Link } from 'react-router';

import {
    Row,
    Col,
    Grid,
    Panel,
    Table,
    Button,
    Icon,
    PanelBody,
    PanelHeader,
    FormControl,
    PanelContainer,
} from '@sketchpixy/rubix';

import {searchRegionChannel} from '../redux/actions/apiActions';
import ChannelListElement from '../components/ChannelListElement';

class  DatatableComponent extends React.Component {
    constructor(props){
        super(props);
        this.state = {};
    }


    componentDidMount() {
        this.updateSearch();
        $(ReactDOM.findDOMNode(this.example))
            .addClass('nowrap')
        //.dataTable({
        //       columnDefs: [
        //           { targets: [-1, -3], className: 'dt-body-left' }
        //       ],
        //   });
    }

    updateSearch(){
        this.searchRegionChannel(localStorage.getItem('key'));
    }

    searchRegionChannel(key){
        this.props.searchRegionChannel(key).then(
            () => this.setState({ channels: this.props.channels})
        )
    }

    render() {
        return (
            <div>
                <div>
                    <Link to={'/ltr/admin/channel/addRegionChannel'}>
                        <Button className="btn btn-success">
                            <Icon glyph='icon-fontello-plus'/>
                        </Button>
                    </Link>
                </div>

                <Table ref={(c) => this.example = c} className='display' cellSpacing='0' width='100%'>
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Channel Name</th>
                            <th>Member Count</th>
                            <th>Description</th>
                            <th>Channel Profile</th>
                            <th>Recount</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.props.channels.map((channel, index) =>{
                            return(
                                <ChannelListElement key={channel.id} channel={channel}/>
                            );
                        })}
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Id</th>
                            <th>Channel Name</th>
                            <th>Member Count</th>
                            <th>Description</th>
                            <th>Channel Profile</th>
                            <th>Recount</th>
                        </tr>
                    </tfoot>
                </Table>
                <locationDelete/>
            </div>
            );
            }
            }

            //@connect((state) => state.locationReducer)
            class ChannelList extends React.Component {
                render() {
                    return (
                        <Row>
                        <Col xs={12}>
                        <PanelContainer>
                            <Panel>
                                <PanelBody>
                                    <Grid>
                                        <Row>
                                            <Col xs={12}>
                                                <DatatableComponent {...this.props}/>
                                                <br/>
                                            </Col>
                                        </Row>
                                    </Grid>
                                </PanelBody>
                            </Panel>
                        </PanelContainer>
                        </Col>
                        </Row>
                    );
                }
            }
            ChannelList.propTypes = {
                searchRegionChannel: React.PropTypes.func.isRequired
            }

            const mapStateToProps = (state) => {
                return {
                    channels: state.channelReducer.channels,
                }

            };

            const myDispatch =  (dispatch, props) => {
                return {
                    dispatch,
                    ...bindActionCreators({
                        searchRegionChannel: searchRegionChannel,
                    }, dispatch)
                }
            };

            export default connect(mapStateToProps, myDispatch)(ChannelList);

