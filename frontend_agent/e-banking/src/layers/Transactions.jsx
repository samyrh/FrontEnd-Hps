import React from "react";
import { Box, Flex, useColorModeValue } from "@chakra-ui/react";
import Sidebar from "../component/Sidebar";
import Navbar from "../component/Navbar";
import CategoryBarChart from "../component/CategoryBarChart";
import CategoryPieChart from "../component/CategoryPieChart";
import IncomePerYear from "../component/IncomePerYear";
import IncomePerMonth from "../component/IncomePerMonth";
import ConfusionMatrix from "../component/ConfusionMatrix";

export default function Transactions() {
    const transactionsPerCategory = [
        { category: "Shopping", count: 120 },
        { category: "Travel", count: 45 },
        { category: "Entertainment", count: 75 },
        { category: "Fees", count: 30 },
        { category: "Utilities", count: 60 },
        { category: "Health", count: 25 },
        { category: "Food", count: 80 },
        { category: "Subscriptions", count: 40 },
        { category: "Education", count: 35 },
        { category: "Insurance", count: 20 },
        { category: "Transfers", count: 50 },
        { category: "Gifts", count: 15 },
        { category: "Savings", count: 22 },
        { category: "Investment", count: 12 },
        { category: "Transportation", count: 55 },
        { category: "Housing", count: 27 },
        { category: "Charity", count: 10 },
        { category: "Taxes", count: 8 },
    ];

    // Example yearly income
    const yearlyLabels = ["2023", "2024", "2025"];
    const yearlyAmounts = [1200000, 1350000, 1450000];

    // Example monthly income
    const monthlyLabels = [
        "2023-01", "2023-02", "2023-03", "2023-04",
        "2023-05", "2023-06", "2023-07", "2023-08",
        "2023-09", "2023-10", "2023-11", "2023-12",
        "2024-01", "2024-02", "2024-03", "2024-04",
    ];
    const monthlyAmounts = [
        320000, 340000, 310000, 360000,
        330000, 350000, 325000, 355000,
        340000, 360000, 330000, 350000,
        370000, 355000, 365000, 375000,
    ];

    // All 18 categories
    const confusionLabels = transactionsPerCategory.map((c) => c.category);

    // Example 18x18 confusion matrix with mostly correct predictions
    const confusionMatrixData = Array.from({ length: 18 }, (_, i) =>
        Array.from({ length: 18 }, (_, j) => (i === j ? 10 : 0))
    );

    const bg = useColorModeValue("#f4f7fe", "#0b1437");

    return (
        <Flex minH="100vh" bg={bg}>
            {/* Sidebar */}
            <Sidebar />

            {/* Main Content */}
            <Box ml="300px" flex="1" display="flex" flexDirection="column">
                {/* Fixed Navbar */}
                <Box position="fixed" top="20px" left="300px" right="20px" zIndex="1000">
                    <Navbar brandText="Transactions Overview" />
                </Box>

                {/* Content Area */}
                <Box
                    pt="180px"
                    px={{ base: "20px", md: "40px", lg: "60px" }}
                    pb="40px"
                    display="grid"
                    gridTemplateColumns={{ base: "1fr", md: "1fr 1fr" }}
                    gap="40px"
                >
                    <CategoryBarChart data={transactionsPerCategory} />
                    <CategoryPieChart data={transactionsPerCategory} />
                    <IncomePerYear labels={yearlyLabels} amounts={yearlyAmounts} />
                    <IncomePerMonth labels={monthlyLabels} amounts={monthlyAmounts} />
                    <Box gridColumn="1 / -1">
                        <ConfusionMatrix labels={confusionLabels} matrix={confusionMatrixData} />
                    </Box>
                </Box>
            </Box>
        </Flex>
    );
}
