import React from 'react';
import './CustomTable.css';

export const CustomTable = ({ children }) => <table className="custom-table">{children}</table>;
export const CustomThead = ({ children }) => <thead className="custom-thead">{children}</thead>;
export const CustomTbody = ({ children }) => <tbody className="custom-tbody">{children}</tbody>;
export const CustomTr = ({ children }) => <tr className="custom-tr">{children}</tr>;
export const CustomTh = ({ children }) => <th className="custom-th">{children}</th>;
export const CustomTd = ({ children }) => <td className="custom-td">{children}</td>;