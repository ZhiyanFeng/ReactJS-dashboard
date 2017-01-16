import React from 'react';
import { connect  } from 'react-redux';
import ReactDOM from 'react-dom';
import _ from 'lodash';

import {
    Row,
    Col,
    Grid,
    Panel,
    Table,
    PanelBody,
    PanelHeader,
    FormControl,
    PanelContainer,
} from '@sketchpixy/rubix';

class DatatableComponent extends React.Component {
    constructor(props){
        super(props);
    }
    componentDidMount() {
        $(ReactDOM.findDOMNode(this.example))
            .addClass('nowrap')
            .dataTable({
                responsive: true,
                columnDefs: [
                    //{ targets: [-1, -3], className: 'dt-body-right' }
                ]
            });
    }

    render() {
        var rows = _.map(this.props.userReducer.users, (user) => {
            return (
                <tr onClick={()=>this.props.selectUser(user)} key={user.id}> 
                    <td>{user.id}</td>
                    <td>{user.first_name}</td>
                    <td>{user.last_name}</td>
                    <td>{user.phone_number}</td>
                    <td></td>
                </tr>
            );
        });
        return (
            <Table ref={(c) => this.example = c} className='display' cellSpacing='0' width='100%'>
                <thead>
                    <tr>
                        <th>Id</th>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Phone Number</th>
                    </tr>
                </thead>
                <tfoot>
                    <tr>
                        <th>Id</th>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Phone Number</th>
                    </tr>
                </tfoot>
                <tbody>
                    {rows}
                </tbody>
            </Table>
        );
    }
}

@connect((state) => state)
export default class Datatablesjs extends React.Component {
    render() {
        console.log('store from tabel class', this.props);
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
