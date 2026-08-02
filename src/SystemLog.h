/****************************************************************************
** File: SystemLog.h
** Date: 21/4/2026
** Author: Rubén Llòria
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License version 2 as
** published by the Free Software Foundation.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/
#ifndef SYSTEMLOG_H
#define SYSTEMLOG_H

#include <QDebug>

// Custom logging macros for the hyper//hiit terminal
// They provide automatic function signature tracing via Q_FUNC_INFO.

#ifndef hDebug
#if defined( HH_DEBUG) && !defined(NDEBUG)
#define hDebug() qDebug() << "[DEBUG]: " << Q_FUNC_INFO
#else
#define hDebug() if(false) qDebug()
#endif
#endif

#ifndef hInfo
#ifdef HH_INFO
#define hInfo() qInfo() << "[INFO]: " << Q_FUNC_INFO
#else
#define hInfo() if(false) qInfo()
#endif
#endif

#ifndef hWarning
#ifdef HH_WARNING
#define hWarning() qWarning() << "[WARNING]: " << Q_FUNC_INFO
#else
#define hWarning() if(false) qWarning()
#endif
#endif

#ifndef hCritical
#ifdef HH_CRITICAL
#define hCritical() qCritical() << "[CRITICAL]: " << Q_FUNC_INFO
#else
#define hCritical() if(false) qCritical()
#endif
#endif

#endif // SYSTEMLOG_H
