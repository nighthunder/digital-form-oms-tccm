import React, {useEffect, useState,} from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';

import './styles.css';

import { connect } from 'react-redux';

 function Modulos({user}) {
    const [responseQuantityModules, setResponseQuantityModules] = useState([]);

    useEffect( () => {
        async function setModules() {
            const { data } = await api.get('/form');
            setResponseQuantityModules(data)
            //console.log("registeredModules", location.state.registeredModules);
        }
        setModules();
    },[])

    const history = useHistory();

    const location = useLocation();

    return (
        <main className="container">
            <div>
                <header className="index">
                    { user[location.state.hospitalIndex].hospitalName } > <b>{ location.state.prontuario }</b>
                </header>
                <h2>Formulário de Registro de caso</h2>
            </div>
            <div className="modulos-list">
                {responseQuantityModules.map((item, index) => (
                    <div key={index}
                        className="item" onClick={ () => {
                    history.push('/formulario', { modulo: item.crfFormsId, hospitalIndex: location.state.hospitalIndex, registeredModules: location.state.registeredModules })
                }}>
                    <h4>Módulo {item.crfFormsId}</h4>
                    <p>{item.description}</p>
                </div>
                ))}
            </div>
        </main>
    );
}

export default connect(state => ({ user: state.user }))(Modulos);