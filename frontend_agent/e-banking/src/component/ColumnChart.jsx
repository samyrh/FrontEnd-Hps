// src/component/ColumnChart.jsx
import React from "react";
import { useColorModeValue } from "@chakra-ui/react";
import ReactApexChart from "react-apexcharts";

const ColumnChart = () => {
    const primaryColor = useColorModeValue('#7551FF', '#7551FF');
    const secondaryColor = useColorModeValue('#38B2AC', '#38B2AC');
    const textColor = useColorModeValue('#2D3748', '#EDF2F7');
    const gridColor = useColorModeValue('#EDF2F7', '#1A202C');

    const chartOptions = {
        chart: {
            type: 'bar',
            toolbar: { show: false },
            foreColor: textColor,
        },
        plotOptions: {
            bar: {
                horizontal: false,
                columnWidth: '40%',
                endingShape: 'rounded',
            },
        },
        xaxis: {
            categories: ['17', '18', '19', '20', '21', '22', '23', '24', '25'],
            labels: { style: { colors: textColor } },
        },
        yaxis: {
            labels: { style: { colors: textColor } },
        },
        grid: {
            borderColor: gridColor,
            strokeDashArray: 4,
        },
        colors: [secondaryColor, primaryColor],
        legend: { show: false },
    };

    const chartData = [
        {
            name: 'Revenue',
            data: [30, 40, 35, 50, 49, 60, 70, 91, 80],
        },
        {
            name: 'Target',
            data: [20, 30, 25, 40, 30, 45, 60, 80, 70],
        },
    ];


    return (
        <ReactApexChart
            options={chartOptions}
            series={chartData}
            type="area"
            width="100%"
            height="100%"
        />
    );

};

export default ColumnChart;
