import React from 'react';
import ReactDOM from 'react-dom';
import { useHistory } from "react-router-dom";
import { Button } from '@material-ui/core';
import ListSurvey from '../listSurvey/index';
import './styles.css';

import { connect } from 'react-redux';

function Hospital({user}) {

    const history = useHistory();

    return (
        <div>
        <main className="container">
            <div>
                <h2>Selecione o hospital</h2>
            </div>
            <div className="modulos-list">
                {user.map((hospital, index) => (
                    <div className="item" key={hospital.hospitalunitid }>
                        <div onClick={ () => {
                            history.push('/prontuario', { hospitalName: hospital.hospitalName, hospitalIndex: index })
                        }}>
                            <h4> {hospital.hospitalName} </h4>
                            <p> {hospital.userrole} </p>
                        </div>
                        
                        { (hospital.userrole === "Administrador") && 
                            <Button variant="contained" color="primary" onClick={ () => {
                                history.push('/cadastro', { hospitalId: hospital.hospitalunitid, hospitalIndex: index})
                            }}>Cadastrar usuários</Button>
                        }
                    </div>
                ))}
            </div>
        </main>
        <main className="container">
           <ListSurvey/>
        </main>
        </div>
    );
}

export default connect(state => ({ user: state.user }))(Hospital);