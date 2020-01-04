<?php


namespace App\Controllers\Admin;

use App\Controllers\Controller;
use PDOException;
use Slim\Http\Request;
use Slim\Http\Response;

class DrinkController extends Controller
{
    /**
     * Display the drink index view to show all drinks
     *
     * @param Request $request
     * @param Response $response
     * @return mixed
     */
    public function indexAction(Request $request, Response $response) {
        // Fetch the pdo connection from the container dependency
        $pdo = $this->container->db;

        $query = $pdo->query("SELECT product_name, unit_name, quantity, price, DATE_FORMAT(startSaleDate, '%d.%m.%Y %H:%i') as startSaleDate, DATE_FORMAT(endSaleDate, '%d.%m.%Y %H:%i') as endSaleDate, alcoholLevel FROM vDrink ORDER BY quantity");
        $drinks = $query->fetchAll();

        return $this->render($response, 'Admin/Drinks/index.html.twig', [
            'drinks' => $drinks
        ]);
    }

    /**
     * Display the drink create view to be able to create a new drink
     *
     * @param Request $request
     * @param Response $response
     * @return mixed
     */
    public function createAction(Request $request, Response $response) {
        // Fetch the pdo connection from the container dependency
        $pdo = $this->container->db;

        $query = $pdo->query("SELECT * FROM UnitMetric");
        $unitMetrics = $query->fetchAll();
        return $this->render($response, 'Admin/Drinks/create.html.twig', [
            'unitMetrics' => $unitMetrics
        ]);
    }

    /**
     * Store a new drink created by the user
     *
     * @param Request $request
     * @param Response $response
     * @return Response
     */
    public function storeAction(Request $request, Response $response)
    {
        // Fetch our form data sent
        $name = $request->getParam('name');
        $nameUnitMetric = $request->getParam('nameUnitMetric');
        $price = $request->getParam('price');
        $startSaleDate = $request->getParam('startSaleDate');
        $endSaleDate = $request->getParam('endSaleDate');
        $alcoholLevel = $request->getParam('alcoholLevel');

        $error = false;

        // Check the required / NOT NULL fields
        if ($this->is_empty($name) || $this->is_empty($nameUnitMetric) || $this->is_empty($price) || $this->is_empty($startSaleDate) || $this->is_empty($alcoholLevel)) {
            $error = true;
        }

        // Fields require OK
        if (!$error) {
            // Fetch the pdo connection from the container dependency
            $pdo = $this->container->db;
            // First, insert the new product
            try {
                $query = $pdo->prepare("INSERT INTO Product(name, nameUnitMetric) VALUES(:name, :nameUnitMetric)");
                $query->execute([
                    ':name' => $name,
                    ':nameUnitMetric' => $nameUnitMetric
                ]);
                $productId = $pdo->lastInsertId();
            } catch (PDOException $exception) {
                $error = true;
            }

            // Second, insert the buyable
            try {
                $query = $pdo->prepare("INSERT INTO Buyable(idProduct, price, startSaleDate, endSaleDate) VALUES(:idProduct, :price, :startSaleDate, :endSaleDate)");
                $query->execute([
                    ':idProduct' => $productId,
                    ':price' => $price,
                    ':startSaleDate' => $startSaleDate,
                    ':endSaleDate' => empty($endSaleDate) ? NULL : $endSaleDate
                ]);
            } catch (PDOException $exception) {
                // If error at this level of inheritance, delete the current product from Product to preserve the DB integrity
                $error = true;
                $pdo->query("DELETE FROM Product WHERE id = " . $productId);
            }

            // Third, insert the drink
            try {
                $query = $pdo->prepare("INSERT INTO Drink(idBuyable, alcoholLevel) VALUES(:idBuyable, :alcoholLevel)");
                $query->execute([
                    ':idBuyable' => $productId,
                    ':alcoholLevel' => $alcoholLevel
                ]);
            } catch (PDOException $exception) {
                // If error at this level of inheritance, delete the current product from Buyable and Product to preserve the DB integrity
                $error = true;
                $pdo->query("DELETE FROM Buyable WHERE idProduct = " . $productId);
                $pdo->query("DELETE FROM Product WHERE id = " . $productId);
            }
        }

        // Error detected -> display flash message
        if($error){
            $this->container->flash->addMessage('error', 'Une erreur est survenue, veuillez vérifier vos données.');
            return $response->withRedirect($this->container->router->pathFor('admin_drinks_create'));
        }

        // No error
        $this->container->flash->addMessage('success', 'La boisson "'.$request->getParam('name').'" à bien été ajoutée.');
        return $response->withRedirect($this->container->router->pathFor('admin_drinks_index'));
    }


    /**
     * Check if the value is empty (zero exclude)
     *
     * @param $val
     * @return bool
     */
    private function is_empty($val) {
        return empty($val) && $val !== "0";
    }

}