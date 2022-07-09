import React from 'react';
import NewInput from '../../components/NewInput';
import ModelSelectType from '../../components/ModelSelectType';
import FormControlLabel from '@mui/material/FormControlLabel';
import { TextField, Button, InputLabel, Select, Checkbox } from '@material-ui/core';
import './styles.css';

export const Form = ({ onSubmit, options, optionsSubordinateQuestion, closeModal, idQuestion }) => {
    const [newQuestionTypeShow, setnewQuestionTypeShow] = React.useState(false);
    const [existsQuestionTypeShow, setExistsQuestionTypeShow] = React.useState(true);
    const [subordinateQuestionShow, setSubordinateQuestionShow] = React.useState(false);

    const [checkedNewQuestionType, setCheckedNewQuestionType] = React.useState(false);
    const [checkedSubordinateQuestion, setCheckedSubordinateQuestion] = React.useState(false);

    const handleChangeCheckboxQuestionType = (event) => {
        setCheckedNewQuestionType(event.target.checked)
        setnewQuestionTypeShow(event.target.checked);
        setExistsQuestionTypeShow(!event.target.checked);
    }

    const handleChangeCheckboxSubordinateQuestion = (event) => {
        setCheckedSubordinateQuestion(event.target.checked)
        setSubordinateQuestionShow(event.target.checked);
    }

    return (
        <form onSubmit={onSubmit} className="formNewQuestions" key={Math.random()}>
            <b><h2>Adicione uma nova pergunta</h2></b>
            <br/>
            <div className="form-group">
                <NewInput descriptionInput={"Descrição da Pergunta"} id={"descricaoPergunta"}/>
                <input type="hidden" id={"idQuestion"} value={idQuestion}></input>
            </div>
            <br/>
            <div className="TipoQuestao">
                <p>Selecione um tipo de questão:</p>
                <FormControlLabel
                    control={
                        <Checkbox checked={checkedNewQuestionType} onChange={handleChangeCheckboxQuestionType} id={"checkboxTipoQuestao"} />
                    }
                    label="Criar novo tipo de lista"
                />
                <br/>
                {existsQuestionTypeShow &&
                    <ModelSelectType
                        id={"selectExistsTypeQuestion"}
                        placeHolder={"Selecione um tipo de questão existente"}
                        options={options}
                    />
                }
                {newQuestionTypeShow &&
                    <div className="form-group">
                        <NewInput descriptionInput={"Tipo novo de questão"} id={"tipoQuestao"}/>
                        <br/>
                        <br/>
                        <NewInput descriptionInput={"Valores de resposta (Exemplo: sim,não,desconhecido)"} id={"valoresRespostas"}/>
                    </div>
                }
            </div>
            <br/>
            <div className="SubordinacaoQuestao">
                <FormControlLabel
                    control={
                        <Checkbox checked={checkedSubordinateQuestion} onChange={handleChangeCheckboxSubordinateQuestion} />
                    }
                    label="Adicionar subordinação a essa questão"
                />
                {subordinateQuestionShow &&
                    <div className="form-group">
                        <ModelSelectType
                            id={"selectSubordinateQuestion"}
                            placeHolder={"Selecione a questão a qual será subordinada"}
                            options={optionsSubordinateQuestion}
                        />
                        <br/>
                        <p>Valores de resposta para subordinação:</p>
                        <br/>
                        <NewInput descriptionInput={"exemplo1,exemplo2,exemplo3..."} id={"valoresRespostasSubodinacao"}/>
                    </div>
                }
            </div>
            <div className="form-group">
                <Button className="form-group-button" variant="contained" color="primary" type="submit">
                    Adicionar
                </Button>
            </div>
        </form>
    );
};
export default Form;
