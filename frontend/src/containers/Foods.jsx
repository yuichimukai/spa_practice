export const Foods = ({ match }) => {
  return (
    <>
      <h2>フード一覧</h2>
      <p>restaurantsIdは{match.params.restaurantsId}です</p>
    </>
  );
};
